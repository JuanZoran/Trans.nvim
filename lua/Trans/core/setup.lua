return function(opts)
    local M = require('Trans')
    if opts then
        M.conf = vim.tbl_deep_extend('force', M.conf, opts)
    end
    local conf   = M.conf
    local set_hl = vim.api.nvim_set_hl
    local hls    = require('Trans.style.theme')[conf.theme]
    for hl, opt in pairs(hls) do
        set_hl(0, hl, opt)
    end


    local path = vim.fn.expand("$HOME/.vim/dict/Trans.json")
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        local status, engine = pcall(vim.json.decode, content)
        assert(status, 'Unable to parse json file: ' .. path)

        conf.engine = engine
    end
end
