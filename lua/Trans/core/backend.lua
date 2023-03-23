local Trans = require 'Trans'


---@class TransBackend
---@field no_wait? boolean whether need to wait for the result
---@field all_name string[] @all backend name
---@field name string @backend name

---@class TransOnlineBackend: TransBackend
---@field uri string @request uri
---@field method 'get' | 'post' @request method
---@field formatter fun(body: table, data: TransData): TransResult|false|nil @formatter
---@field get_query fun(data: TransData): table<string, string> @get query
---@field header? table<string, string> | fun(data: TransData): table<string, string> @request header
---@field debug? fun(body: table?) @debug


local conf = Trans.conf
--- INFO :Parse online engine keys config file
local path = conf.dir .. '/Trans.json'
local file = io.open(path, 'r')


local user_conf = {}
if file then
    local content = file:read '*a'
    user_conf = vim.json.decode(content) or user_conf
    file:close()
end


local all_name = {}
for _, config in ipairs(user_conf) do
    if not config.disable then
        all_name[#all_name + 1] = config.name
        user_conf[config.name] = config
    end
end


---@class TransBackends
---@field all_name string[] all backend names

---@class Trans
---@field backend TransBackends
return setmetatable({
    all_name = all_name,
}, {
    __index = function(self, name)
        ---@type TransBackend
        local backend = require('Trans.backend.' .. name)

        for key, value in pairs(user_conf[name] or {}) do
            backend[key] = value
        end

        self[name] = backend
        return backend
    end,
})
