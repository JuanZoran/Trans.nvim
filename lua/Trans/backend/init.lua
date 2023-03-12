return setmetatable({}, {
    __index = function(t, k)
        local res, engine = pcall(require, [[Trans.backend.]] .. k)
        if not res then
            error([[Fail to load backend: ]] .. k .. '\n  ' .. engine)
        end
        t[k] = engine
        return engine
    end
})
