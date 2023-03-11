local function set_backend_opts(conf)
    local strategys = conf.strategy

    local backend = strategys.backend
    if type(backend) == 'string' then
        strategys.backend = backend == '*' and backend or { backend }
    end

    for i = 2, #conf.backends do
        local name = conf.backends[i]
        if not strategys[name] then
            strategys[name] = {
                frontend = strategys.frontend,
                backend = strategys.backend,
            }
        end
    end
end


local function define_highlights(conf)
    local set_hl = vim.api.nvim_set_hl
    local highlights    = require('Trans.style.theme')[conf.theme]
    for hl, opt in pairs(highlights) do
        set_hl(0, hl, opt)
    end
end

return function(opts)
    local M = require('Trans')
    if opts then
        M.conf = vim.tbl_deep_extend('force', M.conf, opts)
    end
    local conf = M.conf

    set_backend_opts(conf)
    define_highlights(conf)
end
