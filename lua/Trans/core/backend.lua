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



-- TODO :Implement all of utility functions


M.util = m_util
M.random_num = math.random(bit.lshift(1, 15))


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


-- local new = (function()
--     ---@class TransBackend
--     local mt = {
--         ---State hooks
--         ---@param self TransBackend
--         ---@param state TransState @state name
--         ---@param hook fun() hook function
--         ---@param event? TransEvents
--         register = function(self, state, hook, event)
--             table.insert(self.on[state][event], hook)
--         end,

--         ---Update state and Notify hooks
--         ---@param self TransBackend
--         ---@param newstate TransState @state name
--         update = function(self, newstate)
--             -- Enter
--             for _, hook in ipairs(self.on[newstate].enter) do
--                 hook()
--             end

--             -- Leave
--             for _, hook in ipairs(self.on[self.state].leave) do
--                 hook()
--             end

--             -- Change
--             for _, hook in ipairs(self.on[self.state].change) do
--                 hook()
--             end

--             for _, hook in ipairs(self.on[newstate].change) do
--                 hook()
--             end

--             self.state = newstate
--         end,
--     }
--     mt.__index = mt

--     ---TransBackend Constructor
--     ---@param origin TransBackendDefinition
--     ---@return TransBackend
--     return function(origin)
--         origin.on = vim.defaulttable()
--         origin.state = origin.state or 'IDLE'
--         ---@cast origin TransBackend
--         return setmetatable(origin, mt)
--     end
-- end)()

-- local conf = Trans.conf
-- --- INFO :Parse online engine keys config file
-- local path = conf.dir .. '/Trans.json'
-- local file = io.open(path, 'r')


-- local user_conf = {}
-- if file then
--     local content = file:read '*a'
--     user_conf = vim.json.decode(content) or user_conf
--     file:close()
-- end

-- local all_name = {
--     'offline', -- default backend
-- }

-- for _, config in ipairs(user_conf) do
--     if not config.disable then
--         all_name[#all_name + 1] = config.name
--         user_conf[config.name] = config
--     end
-- end

-- ---@class TransBackends
-- ---@field all_name string[] all backend names
-- local M = {
--     all_name = all_name,
-- }

-- ---Template method for online query
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
