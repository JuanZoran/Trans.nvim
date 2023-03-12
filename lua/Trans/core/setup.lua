local Trans = require('Trans')

local function set_strategy_opts(conf)
    local define       = Trans.define
    local all_modes    = define.modes
    local all_backends = define.backends

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
    local all_frontends = Trans.define.frontends


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


local function define_keymaps(conf)
    local set = vim.keymap.set
    local opts = { silent = true, expr = true }


    for _, name in ipairs(Trans.define.frontends) do
        for action, key in pairs(conf.frontend[name].keymap) do
            set('n', key, function()
                local frontend = Trans.frontend[name]
                if frontend.is_available() then
                    frontend.actions[action]()
                else
                    return key
                end
            end, opts)
        end
    end
end



local function define_highlights(conf)
    local set_hl     = vim.api.nvim_set_hl
    local highlights = Trans.style.theme[conf.style.theme]
    for hl, opt in pairs(highlights) do
        set_hl(0, hl, opt)
    end
end

return function(opts)
    if opts then
        Trans.conf = vim.tbl_deep_extend('force', Trans.conf, opts)
    end
    local conf = Trans.conf
    conf.dir = vim.fn.expand(conf.dir)

    set_strategy_opts(conf)
    set_frontend_opts(conf)
    define_keymaps(conf)
    define_highlights(conf)
end
