local Trans = require 'Trans'

---@class TransBackend
---@field no_wait? boolean whether need to wait for the result
---@field name string @backend name
---@field name_zh string @backend name in Chinese

---@class TransOnlineBackend: TransBackend
---@field uri string @request uri
---@field method 'get' | 'post' @request method
---@field formatter fun(body: table, data: TransData): TransResult|false|nil @formatter
---@field get_query fun(data: TransData): table<string, string> @get query
---@field header? table<string, string> | fun(data: TransData): table<string, string> @request header
---@field debug? fun(body: table?) @debug

---@class TransOfflineBackend: TransBackend
---@field query fun(data: TransData)
---@field query_field string[] @query field

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

local all_name = {
    'offline', -- default backend
}

for _, config in ipairs(user_conf) do
    if not config.disable then
        all_name[#all_name + 1] = config.name
        user_conf[config.name] = config
    end
end

---@class TransBackends
---@field all_name string[] all backend names
local M = {
    all_name = all_name,
}

---Template method for online query
---@param data TransData @data
---@param backend TransOnlineBackend @backend
function M.do_query(data, backend)
    local name      = backend.name
    local uri       = backend.uri
    local method    = backend.method
    local formatter = backend.formatter
    local query     = backend.get_query(data)
    local header    = type(backend.header) == 'function' and backend.header(data) or backend.header

    local function handle(output)
        local status, body = pcall(vim.json.decode, output.body)
        if not status or not body then
            if not Trans.conf.debug then
                backend.debug(body)
                data.trace[name] = output
            end

            data.result[name] = false
            return
        end

        data.result[name] = formatter(body, data)
    end

    Trans.curl[method](uri, {
        query = query,
        callback = handle,
        header = header,
    })
    -- Hook ?
end

---@class Trans
---@field backend TransBackends
return setmetatable(M, {
    __index = function(self, name)
        ---@type TransBackend
        local backend = require('Trans.backend.' .. name)

        if user_conf[name] then
            for key, value in pairs(user_conf[name]) do
                backend[key] = value
            end
        end

        self[name] = backend
        return backend
    end,
})
