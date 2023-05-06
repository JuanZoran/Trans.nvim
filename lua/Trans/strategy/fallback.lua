---Fallback query strategy
---@param data TransData
---@return boolean @true if query success
return function(data)
    local result = data.result
    local update
    for _, backend in ipairs(data.backends) do
        local name = backend.name

        if backend.no_wait then
            ---@cast backend TransOfflineBackend
            backend.query(data)
        else
            ---@cast backend TransOnlineBackend
            require 'Trans'.backend.do_query(data, backend)
            update = update or data.frontend:wait()

            while result[name] == nil and update(backend) do
            end
        end

        ---@cast backend TransBackend
        if result[name] then return true end
    end

    return false
end
