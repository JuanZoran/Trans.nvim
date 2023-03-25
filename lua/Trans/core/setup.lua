local Trans = require 'Trans'

local function set_strategy_opts(conf)
    local all_backends = Trans.backend.all_name
    local g_strategy = conf.strategy

    local function parse_backend(backend)
        if type(backend) == 'string' then
            return backend == '*' and all_backends or { backend }
        end

        return backend
    end

    local default_strategy = g_strategy.default
    default_strategy.backend = parse_backend(default_strategy.backend)
    default_strategy.__index = default_strategy

    g_strategy.default = nil

    setmetatable(g_strategy, {
        __index = function()
            return default_strategy
        end,
    })

    for _, strategy in pairs(g_strategy) do
        strategy.backend = parse_backend(strategy.backend)
        setmetatable(strategy, default_strategy)
    end
end



local function define_highlights(conf)
    local set_hl     = vim.api.nvim_set_hl
    local highlights = Trans.style.theme[conf.theme]
    for hl, opt in pairs(highlights) do
        set_hl(0, hl, opt)
    end
end


---@class Trans
---@field setup fun(opts: { mode: string, mode: string })
return function(opts)
    if opts then
        Trans.conf = vim.tbl_deep_extend('force', Trans.conf, opts)
    end
    local conf = Trans.conf
    conf.dir = vim.fn.expand(conf.dir)

    set_strategy_opts(conf)
    define_highlights(conf)
end
