local M = {}
local type_check = require("Trans.util.debug").type_check

local offline_dir = debug.getinfo(1, "S").source:sub(2):match('.*Trans') .. '/component/offline'

M.to_content = function(query_res)
    type_check {
        query_res = { query_res, 'table' }
    }
    local content = {}
    for file in vim.fs.dir(offline_dir) do
        local res = require("Trans.component.offline." .. file:gsub('.lua', '')).to_content(query_res)
        assert(res)
        table.insert(content, res)
    end
    return content
end

return M
