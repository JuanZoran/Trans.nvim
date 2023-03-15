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


---@type table<string, fun(data: TransData, update: fun()): TransResult|false?>
local strategy = {
    fallback = function(data, update)
        local result = data.result

        for _, backend in ipairs(data.backends) do
            ---@cast backend TransBackend
            local name = backend.name
            backend.query(data)

            while result[name] == nil do
                if not update() then
                    break
                end
            end

            if type(result[name]) == 'table' then
                return result[name]
            end
        end
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

        local result = data:get_available_result()
        if result then
            data.frontend:process(data, result)
            return
        end
    end

    local data = Trans.data.new(opts)
    Trans.backend.offline.query(data)
    local result = data.result['offline']
    if not result then
        result = strategy[Trans.conf.query](data, data.frontend:wait())
        if not result then
            data.frontend:fallback()
            return
        end
    end


    Trans.cache[data.str] = data
    data.frontend:process(data, result)
end


---@class Trans
---@field translate fun(opts: { frontend: string?, mode: string?}?) Translate string core function
return function(opts)
    coroutine.wrap(process)(opts)
end
