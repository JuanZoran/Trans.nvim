---Set or Get metatable which will find module in folder
---@param folder_name string
---@param origin table? table to be set metatable
---@return table
local function metatable(folder_name, origin)
    return setmetatable(origin or {}, {
        __index = function(tbl, key)
            local status, result = pcall(require, ('Trans.%s.%s'):format(folder_name, key))
            if status then
                tbl[key] = result
                return result
            end
        end
    })
end


---@class string
---@field width function @Get string display width
---@field play function @Use tts to play string


---@class Trans
---@field style table @Style module
---@field cache table<string, TransData> @Cache for translated data object
local M = metatable('core', {
    style = metatable("style"),
    cache = {},
})

M.metatable = metatable

return M
