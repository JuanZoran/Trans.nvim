local Trans   = require 'Trans'

local db      = require 'sqlite.db'
local path    = Trans.conf.dir .. '/ultimate.db'
local dict    = db:open(path)
local db_name = 'stardict'
vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = function()
        if db:isopen() then db:close() end
    end,
})

---@class TransOfflineBackend
local M = {
    name    = 'offline',
    name_zh = '本地',
    no_wait = true,
}

---@param data any
---@return any
---@overload fun(TransData): TransResult
function M.query(data)
    if data.is_word == false or data.from == 'zh' then
        return
    end

    local res = dict:select(db_name, {
        where = { word = data.str },
        keys  = M.query_field,
        limit = 1,
    })[1]

    data.result.offline = res and M.formatter(res) or false
end

-- this is a awesome plugin
M.query_field = {
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

local function exist(str)
    return str and str ~= ''
end

---@type (fun(res):any)[]
local formatter = {
    title = function(res)
        local title  = {
            word     = res.word,
            oxford   = res.oxford,
            collins  = res.collins,
            phonetic = res.phonetic,
        }

        res.word     = nil
        res.oxford   = nil
        res.collins  = nil
        res.phonetic = nil
        return title
    end,
    tag = function(res)
        if not exist(res.tag) then
            return
        end
        local tag_map = {
            zk    = '中考',
            gk    = '高考',
            ky    = '考研',
            gre   = 'gre ',
            cet4  = '四级',
            cet6  = '六级',
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
        for _, _exchange in ipairs(vim.split(res.exchange, '/', { plain = true })) do
            exchange[exchange_map[_exchange:sub(1, 1)]] = _exchange:sub(3)
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
            pos[pos_map[_pos:sub(1, 1)]] = ('%2s%%'):format(_pos:sub(3))
        end

        return pos
    end,
    translation = function(res)
        if not exist(res.translation) then
            return
        end
        local translation = {}
        for i, _translation in ipairs(vim.split(res.translation, '\n', { plain = true })) do
            translation[i] = _translation
        end

        return translation
    end,
    definition = function(res)
        if not exist(res.definition) then
            return
        end
        local definition = {}
        for i, _definition in ipairs(vim.split(res.definition, '\n', { plain = true })) do
            --     -- TODO :判断是否需要分割空格
            definition[i] = _definition:gsub('^%s+', '', 1)
        end

        return definition
    end,
}

---Formater for TransResul
---@param res TransResult
---@return TransResult
function M.formatter(res)
    for field, func in pairs(formatter) do
        res[field] = func(res)
    end

    return res
end

---@class TransBackends
---@field offline TransOfflineBackend
return M
