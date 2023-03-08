local M = {}

local db = require 'sqlite.db'
local util = require("Trans.backend.util")
vim.api.nvim_create_autocmd('VimLeavePre', {
    once = true,
    callback = function()
        if db:isopen() then
            db:close()
        end
    end
})

M.query = function(opts)
    opts = type(opts) == 'string' and { str = opts } or opts
    if opts.is_word == false then return end

    opts.engine    = 'offline'

    opts.field     = opts.field or M.field
    opts.path      = vim.fn.expand(opts.path or require('Trans').conf.db_path)
    opts.formatter = opts.formatter or M.formatter


    local dict    = db:open(opts.path)
    local db_name = opts.db_name or 'stardict'
    local res     = dict:select(db_name, {
            where = { word = opts.str, },
            keys = opts.field,
            limit = 1,
        })[1]


    if util.is_English(opts.str) then
        opts.from = 'en'
        opts.to = 'zh'
    else
        opts.from = 'zh'
        opts.to = 'en'
    end

    if res then
        opts.result = opts.formatter(res)
    end


    return opts
end

M.nowait = true

M.field = {
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


local formatter = {
    title = function(res)
        res.title = {
            word = res.word,
            oxford = res.oxford,
            collins = res.collins,
            phonetic = res.phonetic,
        }

        res.word = nil
        res.oxford = nil
        res.collins = nil
        res.phonetic = nil
    end,
    tag = function(res)
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
        for i, _exchange in ipairs(vim.split(res.exchange, ' ', { plain = true })) do
            exchange[i] = exchange_map[_exchange]
        end

        return exchange
    end,
    pos = function(res)
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
        for i, _pos in ipairs(vim.split(res.pos, '/', { plain = true })) do
            pos[i] = pos_map[_pos]
        end

        return pos
    end,
    translation = function(res)
        local translation = {}
        for i, _translation in ipairs(vim.split(res.translation, '\n', { plain = true })) do
            translation[i] = _translation
        end

        return translation
    end,
    definition = function(res)
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
