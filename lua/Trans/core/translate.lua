local Trans = require('Trans')
local util = Trans.util

local function init_opts(opts)
    opts = opts or {}
    opts.mode = opts.mode or vim.fn.mode()
    opts.str = util.get_str(opts.mode)
    return opts
end


---To Do Online Query
---@param data TransData @data
---@param backend TransOnlineBackend @backend
local function do_query(data, backend)
    -- TODO : template method for online query
    local name      = backend.name
    local uri       = backend.uri
    local method    = backend.method
    local formatter = backend.formatter
    local query     = backend.get_query(data)
    local header    = type(backend.header) == "function" and backend.header(data) or backend.header

    local function handle(output)
        local status, body = pcall(vim.json.decode, output.body)
        if not status or not body then
            if not Trans.conf.debug then
                backend.debug(body)
                data.trace[name] = output
            end

            data.result[name] = false
            return
        end

        -- vim.print(data.result[name])
        data.result[name] = formatter(body, data)
    end

    Trans.curl[method](uri, {
        query = query,
        callback = handle,
        header = header,
    })
    -- Hook ?
end

---@type table<string, fun(data: TransData):boolean>
local strategy = {
    fallback = function(data)
        local result = data.result
        Trans.backend.offline.query(data)

        if result.offline then return true end

        local update = data.frontend:wait()
        for _, backend in ipairs(data.backends) do
            do_query(data, backend)

            local name = backend.name
            ---@cast backend TransBackend
            while result[name] == nil do
                if not update() then break end
            end

            if result[name] then return true end
        end

        return false
    end,
    --- TODO :More Strategys
}



-- HACK : Core process logic
local function process(opts)
    opts = init_opts(opts)
    local str = opts.str
    if not str or str == '' then return end

    -- Find in cache
    if Trans.cache[str] then
        local data = Trans.cache[str]
        data.frontend:process(data)
        return
    end

    local data = Trans.data.new(opts)
    if strategy[Trans.conf.query](data) then
        Trans.cache[data.str] = data
        data.frontend:process(data)
    else
        data.frontend:fallback()
    end
end


---@class Trans
---@field translate fun(opts: { frontend: string?, mode: string?}?) Translate string core function
return function(opts)
    coroutine.wrap(process)(opts)
end
