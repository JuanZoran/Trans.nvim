local M = {}
-- local type_check = require("Trans.util.debug").type_check


---@param str string
local function is_Chinese(str)
    for i = 1, #str do
        if not str:byte(i) >= [[\u4e00]] then
            return false
        end
    end
    return true
end

return M
