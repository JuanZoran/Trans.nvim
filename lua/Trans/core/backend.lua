local Trans = require 'Trans'

---@class TransBackend
---@field no_wait? boolean whether need to wait for the result
---@field name string
---@field display_text string?
---@field conf table? @User specific config


---@class TransBackendOnline: TransBackend
---@field uri string @request uri
---@field method 'get' | 'post' @request method
---@field formatter fun(body: table, data: TransData): TransResult|false|nil @formatter
---@field get_query fun(data: TransData): table<string, any> @get query table



---@class TransBackendOffline: TransBackend
---@field query fun(data: TransData)



---@class TransBackendCore
local M = {
    ---@type table<string, TransBackend>
    sources = {},
}

local m_util = {}

-- INFO :Template method for online query
-- ---@param data TransData @data
-- ---@param backend TransOnlineBackend @backend
-- function M.do_query(data, backend)
--     local name      = backend.name
--     local uri       = backend.uri
--     local method    = backend.method
--     local formatter = backend.formatter
--     local query     = backend.get_query(data)
--     local header    = type(backend.header) == 'function' and backend.header(data) or backend.header

--     local function handle(output)
--         local status, body = pcall(vim.json.decode, output.body)
--         if not status or not body then
--             if not Trans.conf.debug then
--                 backend.debug(body)
--                 data.trace[name] = output
--             end

--             data.result[name] = false
--             return
--         end

--         data.result[name] = formatter(body, data)
--     end

--     Trans.curl[method](uri, {
--         query = query,
--         callback = handle,
--         header = header,
--     })
--     -- Hook ?
-- end






-- TODO :Implement all of utility functions


M.util = m_util
M.random_num = math.random(bit.lshift(1, 15))

-- INFO :Parse configuration file
local path = Trans.conf.dir .. '/Trans.json'
local file = io.open(path, 'r')
local user_conf = {}
if file then
    local content = file:read '*a'
    user_conf = vim.json.decode(content) or user_conf
    file:close()
end
-- WARNING : [Breaking change] 'Trans.json' should use json object instead of array

---@class Trans
---@field backend TransBackendCore
return setmetatable(M, {
    __index = function(self, name)
        ---@type TransBackend
        local backend = require('Trans.backend.' .. name)
        backend.conf = user_conf[name]

        self.sources[name] = backend
        return backend
    end,
})
