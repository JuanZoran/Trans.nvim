local M = {}
 
local buf_opts = {
}

local buf = vim.api.nvim_create_buf(false, true)

M.buf = buf

M.augroup = vim.api.nvim_create_augroup('Trans', { clear = true })

return M
