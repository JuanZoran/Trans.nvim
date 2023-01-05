local M = {}

--[[
content = {
    lines = {}          ---@type string[]
    highlight = {}
}
--]]
---@param contents string[]
M.set = function (win, contents)
    vim.validate {
        contents = { contents, 'table' },
    }
    -- TODO 
end


return M
