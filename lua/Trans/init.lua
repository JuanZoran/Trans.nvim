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

local uname = vim.loop.os_uname().sysname
local system =
    uname == 'Darwin' and 'mac' or
    uname == 'Windows_NT' and 'win' or
    uname == 'Linux' and (vim.fn.executable 'termux-api-start' == 1 and 'termux' or 'linux') or
    error 'Unknown System, Please Report Issue'

---@class Trans
---@field style table @Style module
---@field cache table<string, TransData> @Cache for translated data object
---@field plugin_dir string @Plugin directory
---@field system 'mac'|'win'|'termux'|'linux' @Operating system
local M = metatable('core', {
    cache      = {},
    style      = metatable 'style',
    system     = system,
    plugin_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h:h'),
})

M.metatable = metatable

return M
