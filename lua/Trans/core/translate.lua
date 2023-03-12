local Trans = require('Trans')
local util = Trans.util

vim.pretty_print(Trans.conf)
local function new_data(opts)
    opts = opts or {}
    local mode = opts.method or ({
        n = 'normal',
        v = 'visual',
    })[vim.api.nvim_get_mode().mode]

    local str = util.get_str(mode)
    if str == '' then return end

    local strategy = Trans.conf.strategy[mode]
    local data = {
        str = str,
        mode = mode,
        frontend = strategy.frontend,
        backend = strategy.backend,
        result = {},
    }

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
    -- local t_backend = require('Trans').backend
    -- for _, name in rdata.backend do
    --     local backend = t_backend[name]
    --     backend.query(data)
    --     if backend.no_wait then

    --     end
    -- end

    -- Trans.backend.baidu.query(data)
    -- local thread = coroutine.running()
    -- local resume = function()
    --     coroutine.resume(thread)
    -- end

    -- local time = 0
    -- while data.result == nil do
    --     vim.defer_fn(resume, 400)
    --     time = time + 1
    --     print('waiting' .. ('.'):rep(time))
    --     coroutine.yield()
    -- end
    -- vim.pretty_print(data)
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
