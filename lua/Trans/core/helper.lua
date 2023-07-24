local fn, api = vim.fn, vim.api
local Trans = require 'Trans'

---@class TransHelper for Trans module dev
local M = {}


---Get abs_path of file
---@param path string[]
---@param is_dir boolean? [default]: false
---@return string @Generated path
function M.relative_path(path, is_dir)
    return Trans.plugin_dir .. table.concat(path, Trans.separator) .. (is_dir and Trans.separator or '')
end




return M
