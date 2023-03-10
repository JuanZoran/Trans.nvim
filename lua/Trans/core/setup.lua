return function(opts)
    local M = require('Trans')
    if opts then
        M.conf = vim.tbl_deep_extend('force', M.conf, opts)
    end

    local set_hl = vim.api.nvim_set_hl
    local hls    = require('Trans.style.theme')[M.conf.theme]
    for hl, opt in pairs(hls) do
        set_hl(0, hl, opt)
    end
end
