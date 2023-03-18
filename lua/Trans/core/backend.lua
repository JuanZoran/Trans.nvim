local Trans = require('Trans')


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
local file = io.open(path, "r")

local result = {}
if file then
    local content = file:read("*a")
    result = vim.json.decode(content) or result
    file:close()
end


local all_name = {}
local backend_order = conf.backend_order or vim.tbl_keys(result)
for _, name in ipairs(backend_order) do
    if not result[name].disable then
        all_name[#all_name + 1] = name
    end
end


---@class Trans
---@field backend table<string, TransBackend>
return setmetatable({
    all_name = all_name,
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
            for field, value in pairs(private_opts) do
                backend[field] = value
            end
        end

        return backend
    end
})
