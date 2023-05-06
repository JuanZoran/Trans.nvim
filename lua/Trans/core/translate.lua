local Trans = require 'Trans'

-- HACK : Core process logic
local function process(opts)
    opts = opts or {}
    opts.mode = opts.mode or vim.fn.mode()
    local str = Trans.util.get_str(opts.mode)
    opts.str = str

    if not str or str == '' then return end


    -- Find in cache
    if Trans.cache[str] then
        local data = Trans.cache[str]
        data.frontend:process(data)
        return
    end

    local data = Trans.data.new(opts)
    if Trans.strategy[data.frontend.opts.query](data) then
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
