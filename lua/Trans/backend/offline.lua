local M = { no_wait = true }

local db = require 'sqlite.db'
vim.api.nvim_create_autocmd('VimLeavePre', {
    once = true,
    callback = function()
        if db:isopen() then
            db:close()
        end
    end
})

M.query = function(data)
    if data.is_word == false or data.from == 'zh' then return end

    data.path        = vim.fn.expand(data.path or require('Trans').conf.dir .. '/ultimate.db')
    data.engine      = 'offline'
    data.formatter   = data.formatter or M.formatter
    data.query_field = data.query_field or M.query_field


    local dict    = db:open(data.path)
    local db_name = data.db_name or 'stardict'
    local res     = dict:select(db_name, {
            where = { word = data.str, },
            keys = data.query_field,
            limit = 1,
        })[1]

    if res then
        data.result = data.formatter(res)
    end


    return data
end

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

local exist = function(str)
    return str and str ~= ''
end

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
        if not exist(res.tag) then return end
        local tag_map = {
            zk    = '中考',
            gk    = '高考',
            ky    = '考研',
            cet4  = '四级',
            cet6  = '六级',
            ielts = '雅思',
            toefl = '托福',
            gre   = 'gre ',
        }

        local tag = {}
        for i, _tag in ipairs(vim.split(res.tag, ' ', { plain = true })) do
            tag[i] = tag_map[_tag]
        end

        return tag
    end,
    exchange = function(res)
        if not exist(res.exchange) then return end
        local exchange_map = {
                ['p'] = '过去式      ',
                ['d'] = '过去分词    ',
                ['i'] = '现在分词    ',
                ['r'] = '比较级      ',
                ['t'] = '最高级      ',
                ['s'] = '复数        ',
                ['0'] = '原型        ',
                ['1'] = '类别        ',
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
        if not exist(res.pos) then return end
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
            pos[pos_map[_pos:sub(1, 1)]] = _pos:sub(3)
        end

        return pos
    end,
    translation = function(res)
        if not exist(res.translation) then return end
        local translation = {}
        for i, _translation in ipairs(vim.split(res.translation, '\n', { plain = true })) do
            translation[i] = _translation
        end

        return translation
    end,
    definition = function(res)
        if not exist(res.definition) then return end
        local definition = {}
        for i, _definition in ipairs(vim.split(res.definition, '\n', { plain = true })) do
            --     -- TODO :判断是否需要分割空格
            definition[i] = _definition:gsub('^%s+', '', 1)
        end

        return definition
    end,
}


M.formatter = function(res)
    for field, func in pairs(formatter) do
        res[field] = func(res)
    end

    return res
end

return M
