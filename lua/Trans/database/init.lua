local M = {}
local _, db = pcall(require, 'sqlite.db')
if not _ then
    error('Please check out sqlite.lua')
end

-- INFO : init database
local path = require("Trans").conf.db_path
local dict = db:open(path)

-- INFO :Auto Close
vim.api.nvim_create_autocmd('VimLeavePre', {
    group = require("Trans.conf.base").autogroup,
    callback = function ()
        if db:isopen() then
            db:close()
        end
    end
})

M.query = function (arg)
    -- TODO : more opts
    local res = dict:select('stardict', {
        where = { word = arg },
    })
    return res[1]
end

return M
