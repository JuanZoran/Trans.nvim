return setmetatable({}, {
    __index = function(t, k)
        local res, engine = pcall(require, [[Trans.backend.]] .. k)
        assert(res, [[No such Backend: ]] .. k)
        t[k] = engine
        return engine
    end
})
