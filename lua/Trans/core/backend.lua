local Trans = require('Trans')


---@class TransBackend
---@field query fun(data: TransData)---@async
---@field no_wait? boolean whether need to wait for the result
---@field all_name string[] @all backend name
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

local all_name = {}
for name, opts in pairs(result) do
    if opts.disable then
        result[name] = nil
    else
        all_name[#all_name + 1] = name
    end
end


---@class Trans
---@field backend table<string, TransBackend>
return setmetatable({
    all_name = Trans.conf.backend_order or all_name,
}, {
    __index = function(self, name)
        ---@type TransBackend
        local backend = require('Trans.backend.' .. name)
        if backend then
            self[name] = backend
        else
            backend = self[name]
        end

        local private_opts = result[name]
        if private_opts then
            for k, v in pairs(private_opts) do
                backend[k] = v
            end
        end

        return backend
    end
})
