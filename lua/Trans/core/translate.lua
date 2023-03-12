local Trans = require('Trans')
local util = Trans.util


local function init_opts(opts)
    opts = opts or {}
    opts.mode = opts.mode or ({
        n = 'normal',
        v = 'visual',
    })[vim.api.nvim_get_mode().mode]

    opts.str = util.get_str(opts.mode)
    return opts
end


local function new_data(opts)
    local mode = opts.mode
    local str  = opts.str


    local strategy = Trans.conf.strategy[mode]
    local data     = {
        str    = str,
        mode   = mode,
        result = {},
    }

    data.frontend  = Trans.frontend[strategy.frontend].new()

    data.backend   = {}
    for i, name in ipairs(strategy.backend) do
        data.backend[i] = Trans.backend[name]
    end


    if util.is_English(str) then
        data.from = 'en'
        data.to = 'zh'
    else
        data.from = 'zh'
        data.to = 'en'
    end

    -- FIXME : Check if the str is a word
    data.is_word = true

    return data
end

local function set_result(data)
    -- HACK :Rewrite this function to support multi requests
    local frontend = data.frontend
    for _, backend in ipairs(data.backend) do
        local name = backend.name
        if backend.no_wait then
            backend.query(data)
        else
            backend.query(data)
            frontend:wait(data.result, name, backend.timeout)
        end

        if type(data.result[name]) == 'table' then break end
    end
end


-- HACK : Core process logic
local function process(opts)
    Trans.translate = coroutine.wrap(process)
    opts = init_opts(opts)
    local str = opts.str
    if not str or str == '' then return end

    -- Find in cache
    if Trans.cache[str] then
        local data = Trans.cache[str]
        data.frontend:process(data)
        return
    end



    local data = new_data(opts)
    set_result(data)
    local success = false
    for _, v in pairs(data.result) do
        if type(v) == "table" then
            success = true
            break
        end
    end
    if success == false then return end

    Trans.cache[data.str] = data
    data.frontend:process(data)
end

return coroutine.wrap(process)
