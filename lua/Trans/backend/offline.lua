local Trans = require 'Trans'
local api = vim.api
local uv = vim.loop
local fn = vim.fn
local function current_offline_conf()
    local conf = Trans.conf.offline or {}
    return {
        filename = conf.filename or 'ultimate.db',
        db_name = conf.db_name or 'stardict',
        debug = conf.debug == true,
    }
end

---@class TransOfflineBackend
local M = {
    name = 'offline',
    name_zh = '本地',
    no_wait = true,
}

local dict_path
local load_error
local notify = vim.notify

local function trace_debug(msg)
    if not msg then
        return
    end
    local offline_conf = current_offline_conf()
    if not offline_conf.debug then
        return
    end
    vim.schedule(function()
        notify('[Trans offline] ' .. msg, vim.log.levels.INFO)
    end)
end

local function path_join(dir, name, sep)
    if not dir then
        return name
    end
    sep = sep or Trans.separator
    if dir:sub(-1) == sep then
        return dir .. name
    end
    return dir .. sep .. name
end

local columns = {
    'word',
    'phonetic',
    'definition',
    'translation',
    'pos',
    'collins',
    'oxford',
    'tag',
    'exchange',
}
local sep = '\x1f'

local function ensure_dict()
    if dict_path then
        return dict_path
    end

    load_error = nil
    local base_dir = Trans.conf.dir
    local offline_conf = current_offline_conf()
    local candidate = path_join(base_dir, offline_conf.filename)
    if not uv.fs_stat(candidate) then
        load_error = 'missing_dictionary'
        trace_debug('dictionary missing at ' .. candidate)
        return nil
    end

    dict_path = candidate
    trace_debug('dictionary ready: ' .. dict_path)
    return dict_path
end

local function parse_cli_row(raw)
    raw = raw:gsub('[\r\n]+$', '')
    if raw == '' then
        return nil
    end

    local fields = {}
    local last = 1
    for i = 1, #columns - 1 do
        local idx = raw:find(sep, last, true)
        if not idx then
            trace_debug('unexpected sqlite3 output: ' .. raw)
            return nil
        end
        fields[i] = raw:sub(last, idx - 1)
        last = idx + 1
    end
    fields[#columns] = raw:sub(last)

    local row = {}
    for i, key in ipairs(columns) do
        row[key] = fields[i] or ''
    end

    return row
end

local function query_row_with_cli(data, word, db_path, offline_conf)
    local raw_sql = string.format(
        'SELECT %s FROM %s WHERE word = %s LIMIT 1',
        table.concat(columns, ','),
        offline_conf.db_name,
        fn.shellescape(word)
    )
    local args = { 'sqlite3', '-separator', sep, db_path, raw_sql }
    local start = uv and uv.hrtime()
    local raw_lines = fn.systemlist(args)
    if start and uv then
        local duration_ms = (uv.hrtime() - start) / 1e6
        data.trace.offline_query_ms = duration_ms
    end
    if vim.v.shell_error ~= 0 then
        local raw = table.concat(raw_lines, '\n')
        load_error = 'cli_query_failed'
        trace_debug('sqlite3 failed: ' .. raw)
        return nil
    end

    local raw = table.concat(raw_lines, '\n')
    return parse_cli_row(raw)
end

local function split_lines(text)
    if not text or text == '' then
        return nil
    end

    local lines = {}
    for line in text:gmatch('([^\n]*)\n?') do
        if line == '' and #lines == 0 then
            -- skip leading empty
        else
            lines[#lines + 1] = line
        end
    end

    return #lines > 0 and lines or nil
end

local function exist(str)
    return str and str ~= ''
end

---@type (fun(res):any)[]
local formatter = {
    title = function(res)
        local title = {
            word = res.word,
            oxford = res.oxford,
            collins = res.collins,
            phonetic = res.phonetic,
        }

        res.word = nil
        res.oxford = nil
        res.collins = nil
        res.phonetic = nil
        return title
    end,
    tag = function(res)
        if not exist(res.tag) then
            return
        end
        local tag_map = {
            zk = '中考',
            gk = '高考',
            ky = '考研',
            gre = 'gre ',
            cet4 = '四级',
            cet6 = '六级',
            ielts = '雅思',
            toefl = '托福',
        }

        local tag = {}
        for i, _tag in ipairs(vim.split(res.tag, ' ', { plain = true })) do
            tag[i] = tag_map[_tag]
        end

        return tag
    end,
    exchange = function(res)
        if not exist(res.exchange) then
            return
        end
        local exchange_map = {
            ['0'] = '原型        ',
            ['1'] = '类别        ',
            ['p'] = '过去式      ',
            ['r'] = '比较级      ',
            ['t'] = '最高级      ',
            ['b'] = '比较级      ',
            ['z'] = '最高级      ',
            ['s'] = '复数        ',
            ['d'] = '过去分词    ',
            ['i'] = '现在分词    ',
            ['3'] = '第三人称单数',
            ['f'] = '第三人称单数',
        }

        local exchange = {}
        for code, value in res.exchange:gmatch '([0-9a-zA-Z])/([^/]+)' do
            local label = exchange_map[code]
            if label then
                exchange[label] = value
            end
        end

        return exchange
    end,
    pos = function(res)
        if not exist(res.pos) then
            return
        end
        local pos_map = {
            a = '代词pron         ',
            c = '连接词conj       ',
            i = '介词prep         ',
            j = '形容词adj        ',
            m = '数词num          ',
            n = '名词n            ',
            p = '代词pron         ',
            r = '副词adv          ',
            u = '感叹词int        ',
            v = '动词v            ',
            x = '否定标记not      ',
            t = '不定式标记infm   ',
            d = '限定词determiner ',
        }

        local pos = {}
        for _, _pos in ipairs(vim.split(res.pos, '/', { plain = true })) do
            local key = _pos:sub(1, 1)
            local name = pos_map[key]
            if name then
                pos[name] = ('%2s%%'):format(_pos:sub(3))
            end
        end

        return pos
    end,
    translation = function(res)
        return split_lines(res.translation)
    end,
    definition = function(res)
        return split_lines(res.definition)
    end,
}

---@field query fun(data: TransData)
function M.query(data)
    if data.is_word == false or data.from == 'zh' then
        return
    end

    local db_path = ensure_dict()
    if not db_path then
        data.trace.offline = load_error
        data.result.offline = false
        return
    end

    local offline_conf = current_offline_conf()
    local row = query_row_with_cli(data, data.str, db_path, offline_conf)
    if not row then
        data.trace.offline = load_error
        data.result.offline = false
        return
    end

    data.result.offline = M.formatter(row)
end

function M.formatter(res)
    for field, func in pairs(formatter) do
        res[field] = func(res)
    end
    return res
end

return M
