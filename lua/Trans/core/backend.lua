local Trans = require('Trans')
local conf = Trans.conf

--- INFO :Parse online engine keys config file
local path = conf.dir .. '/Trans.json'
local file = io.open(path, "r")


local result = {}
if file then
    local content = file:read("*a")
    result = vim.json.decode(content) or result
    file:close()
end

return setmetatable({}, {
    __index = function(self, name)
        local opts = vim.tbl_extend('keep', conf.backend[name] or {}, conf.backend.default, result[name] or {})
        local backend = require('Trans.backend.' .. name)

        for k, v in pairs(opts) do
            backend[k] = v
        end

        self[name] = backend
        return backend
    end
})
