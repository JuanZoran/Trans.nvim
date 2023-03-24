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
        end,
    })
end

---@class string
---@field width function @Get string display width
---@field play function @Use tts to play string


local sep = vim.loop.os_uname().sysname == 'Windows' and '\\' or '/'
---@class Trans
---@field style table @Style module
---@field cache table<string, TransData> @Cache for translated data object
---@field plugin_dir string @Plugin directory
---@field separator string @Path separator
local M = metatable('core', {
    cache      = {},
    style      = metatable 'style',
    plugin_dir = debug.getinfo(1, 'S').source:sub(2):match('(.-)lua' .. sep .. 'Trans'),
    separator  = sep,
})

M.metatable = metatable

---Get abs_path of file
---@param path string[]
---@param is_dir boolean?
---@return string
function M.relative_path(path, is_dir)
    return M.plugin_dir .. table.concat(path, sep) .. (is_dir and sep or '')
end

return M
