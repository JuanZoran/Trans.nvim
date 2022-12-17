local M = {}
-- local db = require('Trans').db
local dict = require("Trans").dict

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

    vim.pretty_print(res)
    return res[1]
end

return M
