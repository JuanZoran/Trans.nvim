---Set or Get metatable which will find module in folder
---@param folder_name string
---@param origin table?
---@return table
local function metatable(folder_name, origin)
    return setmetatable(origin or {}, {
        __index = function(tbl, key)
            local status, result = pcall(require, ('Trans.%s.%s'):format(folder_name, key))

            if not status then
                error('fail to load: ' .. key .. '\n' .. result)
            end

            tbl[key] = result
            return result
        end
    })
end

local M = metatable('core')


M.metatable = metatable
M.style     = metatable("style")
M.wrapper   = metatable("wrapper")

M.cache = {}
return M
