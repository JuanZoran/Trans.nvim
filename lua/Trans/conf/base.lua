local M = {}

local buf_opts = {
    filetype = 'Trans'
}

local buf = vim.api.nvim_create_buf(false, true)
for k, v in pairs(buf_opts) do
    vim.api.nvim_buf_set_option(buf, k, v)
end

M.buf = buf

M.group = vim.api.nvim_create_augroup('Trans', { clear = true })


return M
