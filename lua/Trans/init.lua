local M = setmetatable({}, {
    __index = function(tbl, key)
        local status, field = pcall(require, 'Trans.core.' .. key)
        assert(status, 'Unknown field: ' .. key)
        
        tbl[key] = field
        return field
    end
})

M.cache = {}

return M
