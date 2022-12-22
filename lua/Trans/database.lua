local M = {}
local db_path = require("Trans").conf.db_path
local dict = require("Trans").db:open(db_path)

function M.query(arg)
    -- TODO: return type: a result table:
    local res = {}
    if type(arg) == 'string' then
        res = dict:select('stardict', {
            where = { word = arg },
        })
    elseif type(arg) == 'table' then
        res = dict:select('stardict', arg)
    else
        vim.notify('query argument error!')
    end
    return res[1]
end

return M
