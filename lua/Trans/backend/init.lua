local M = {}


M.__index = function(tbl, k)
    local res, engine = pcall(require, 'Trans.backend.' .. k)
    assert(res, [[Can't Found Engine:]] .. k)

    tbl[k] = engine
    return engine
end


return setmetatable(M, M)
