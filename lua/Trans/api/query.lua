local M = {}
local _, db = pcall(require, 'sqlite.db')
if not _ then
    error('Please check out sqlite.lua')
end
local type_check = require("Trans.util.debug").type_check

-- INFO : init database
local path = require("Trans.conf.loader").loaded_conf.base.db_path
local dict = db:open(path)

-- INFO :Auto Close
vim.api.nvim_create_autocmd('VimLeavePre', {
    group = require("Trans").augroup,
    callback = function()
        if db:isopen() then
            db:close()
        end
    end
})

local query_field = {
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

-- NOTE : local query
M.query = function(arg)
    -- TODO : more opts
    type_check {
        arg = { arg, 'string' },
    }
    local res = dict:select('stardict', {
        where = {
            word = arg,
        },
        keys = query_field,
    })
    return res[1]
end


return M
