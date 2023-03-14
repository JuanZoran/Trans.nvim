local Trans = require('Trans')


---@class TransBackend
---@field query fun(TransData): TransResult
---@field opts TransBackendOpts
---@field no_wait? boolean whether need to wait for the result
---@field name string @backend name


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


local default_opts = conf.backend.default
default_opts.__index = default_opts

---@class Trans
---@field backend table<string, TransBackend>
return setmetatable({}, {
    __index = function(self, name)
        ---@type TransBackend
        local backend = require('Trans.backend.' .. name)
        if backend then
            self[name] = backend
        else
            backend = self[name]
        end

        backend.opts = setmetatable(conf.backend[name] or {}, default_opts)

        local private_opts = result[name]
        if private_opts then
            for k, v in pairs(private_opts) do
                backend[k] = v
            end
        end

        return backend
    end
})
