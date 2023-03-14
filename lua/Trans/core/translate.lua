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


local function do_query(data)
    -- HACK :Rewrite this function to support multi requests
    local frontend = data.frontend
    local result = data.result
    for _, backend in ipairs(data.backend) do
        local name = backend.name
        if backend.no_wait then
            backend.query(data)
        else
            backend.query(data)
            frontend:wait(result, name, backend.timeout)
        end


        if type(result[name]) == 'table' then
            return result[name]
        else
            result[name] = nil
        end
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

        local result = data:get_available_result()
        if result then
            data.frontend:process(data, result)
            return
        end
    end


    local data = Trans.data.new(opts)
    local result = do_query(data)

    if not result then return end
    Trans.cache[data.str] = data
    data.frontend:process(data, result)
end

return coroutine.wrap(process)
