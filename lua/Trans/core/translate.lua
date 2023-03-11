local Trans = require('Trans')
local util = Trans.util

local backends = Trans.conf.backends

local function new_data(opts)
    opts = opts or {}
    local method = opts.method or ({
        n = 'normal',
        v = 'visual',
    })[vim.api.nvim_get_mode().mode]

    local str = util.get_str(method)
    if str == '' then return end

    local strategy = Trans.conf.strategy[method] or Trans.conf.strategy
    local data = {
        str = str,
        method = method,
        frontend = strategy.frontend,
        result = {},
    }

    local backend = strategy.backend
    if type(backend) == 'string' then
        backend = backend == '*' and backends or { backend }
    end
    data.backend = backend

    if util.is_English(str) then
        data.from = 'en'
        data.to = 'zh'
    else
        data.from = 'zh'
        data.to = 'en'
    end
    return data
end

local function set_result(data)
    local t_backend = require('Trans.backend')
    for _, name in data.backend do
        local backend = t_backend[name]
        backend.query(data)
        if backend.no_wait then

        end
    end

    require('Trans.backend').baidu.query(data)
    local thread = coroutine.running()
    local resume = function()
        coroutine.resume(thread)
    end

    local time = 0
    while data.result == nil do
        vim.defer_fn(resume, 400)
        time = time + 1
        print('waiting' .. ('.'):rep(time))
        coroutine.yield()
    end
    vim.pretty_print(data)
end

local function render_window()

end

-- HACK : Core process logic
local function process(opts)
    Trans.translate = coroutine.wrap(process)

    local data = new_data(opts)
    if not data then return end

    set_result(data)
    if data.result == false then return end

    render_window()
end

return coroutine.wrap(process)
