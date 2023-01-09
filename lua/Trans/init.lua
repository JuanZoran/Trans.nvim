local M = {}

M.setup = function(opts)
    require('Trans.conf.loader').load_conf(opts)
    require("Trans.setup")
    M.translate = require('Trans.core.translate')
end

M.translate = nil
M.augroup = vim.api.nvim_create_augroup('Trans', {clear = true})

return M
