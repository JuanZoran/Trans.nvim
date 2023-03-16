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


---@type table<string, fun(data: TransData): true | nil>
local strategy = {
    fallback = function(data)
        local result = data.result
        Trans.backend.offline.query(data)
        if result.offline then return true end


        local update = data.frontend:wait()
        for _, backend in ipairs(data.backends) do
            ---@cast backend TransBackend
            backend.query(data)
            local name = backend.name

            while result[name] == nil do
                if not update() then return end
            end

            if result[name] then return true end
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
        data.frontend:process(data)
        return
    end

    local data = Trans.data.new(opts)
    if strategy[Trans.conf.query](data) then
        Trans.cache[data.str] = data
    end

    data.frontend:process(data)
end


---@class Trans
---@field translate fun(opts: { frontend: string?, mode: string?}?) Translate string core function
return function(opts)
    coroutine.wrap(process)(opts)
end
