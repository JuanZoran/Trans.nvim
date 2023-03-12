local function set_strategy_opts(conf)
    local define       = require('Trans').define
    local all_modes    = define.modes
    local all_backends = vim.tbl_keys(conf.engines)

    -- FIXME : Wrong backend baidu
    local function parse_backend(backend)
        if type(backend) == 'string' then
            return backend == '*' and all_backends or { backend }
        end

        return backend
    end
    local global_strategy = conf.strategy
    global_strategy.backend = parse_backend(global_strategy.backend)


    local meta = {
        __index = function(tbl, key)
            tbl[key] = global_strategy[key]
            return tbl[key]
        end
    }


    for _, mode in ipairs(all_modes) do
        if not global_strategy[mode] then
            global_strategy[mode] = setmetatable({}, meta)
        else
            if mode.backend then
                mode.backend = parse_backend(mode.backend)
            end

            setmetatable(mode, meta)
        end
    end
end


local function set_frontend_opts(conf)
    local all_frontends = require('Trans').define.frontends


    local global_frontend_opts = conf.frontend
    local meta = {
        __index = function(tbl, key)
            tbl[key] = global_frontend_opts[key]
            return tbl[key]
        end
    }

    for _, frontend in ipairs(all_frontends) do
        local frontend_opts = global_frontend_opts[frontend]
        if not frontend_opts then
            global_frontend_opts[frontend] = setmetatable({}, meta)
        else
            setmetatable(frontend_opts, meta)
        end
    end
end



local function define_highlights(conf)
    local set_hl     = vim.api.nvim_set_hl
    local highlights = require('Trans.style.theme')[conf.style.theme]
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
    conf.dir = vim.fn.expand(conf.dir)

    set_strategy_opts(conf)
    set_frontend_opts(conf)
    define_highlights(conf)
end
