local M = {}

local db = require 'sqlite.db'
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


    local str       = opts.str
    local path      = opts.path or require('Trans').conf.db_path
    local formatter = opts.formatter or M.formatter
    local field     = M.field or M.field


    local dict    = db:open(path)
    local db_name = opts.db_name or 'stardict'
    local res     = dict:select(db_name, {
            where = { word = str, },
            keys = field,
            limit = 1,
        })[1]


    local ret = {
        -- from = '',
        -- to = '',
        engine = 'offline',
    }

    if res then
        res.result = formatter(res)
        -- TODO 
    else
        -- TODO :
    end

    return ret
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


M.formatter = function(res)
    res.title = {
        word = res.word,
        oxford = res.oxford,
        collins = res.collins,
        phonetic = res.phonetic,
    }

    return res
end

return M
