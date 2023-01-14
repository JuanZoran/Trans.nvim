local M = {}
local _, db = pcall(require, 'sqlite.db')
if not _ then
    error('Please check out sqlite.lua')
end

-- INFO : init database
local path = require('Trans').conf.db_path
local dict = db:open(path)

local query_fields = {
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


local routes = {
    offline = function(word)
        local res = dict:select('stardict', {
            where = {
                word = word,
            },
            keys = query_fields,
        })
        return res[1]
    end,
}


-- INFO :Auto Close
vim.api.nvim_create_autocmd('VimLeavePre', {
    group = require("Trans").augroup,
    callback = function()
        if db:isopen() then
            db:close()
        end
    end
})


-- NOTE : local query
M.query = function(engine, word)
    -- TODO : more opts
    vim.validate {
        word = {word, 's'},
        engine = {word, 's'},
    }

    return routes[engine](word)
end


return M
