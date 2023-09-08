local Trans = require 'Trans'

---@class TransBackend
---@field no_wait? boolean whether need to wait for the result
---@field name string
---@field display_text string?
---@field conf table? @User specific config


---@class TransBackendOnline: TransBackend
---@field uri string @request uri
---@field method 'get' | 'post' @request method
---@field formatter fun(body: table, data: TransData): TransResult|false|nil transform response body to TransResult
---@field get_query fun(data: TransData): table<string, any> @get query table
---@field error_message? fun(errorCode) @get error message

-- -@field header table<string, string>|fun(data: TransData): table<string, string> @request header


---@class TransBackendOffline: TransBackend
---@field query fun(data: TransData)



---@class TransBackendCore
local M = {
    ---@type table<string, TransBackend> backendname -> backend source
    sources = {},
}

local m_util = {}

-- INFO :Template method for online query
---@param data TransData @data
---@param backend TransBackendOnline @backend
function M.do_query(data, backend)
    local name      = backend.name
    local formatter = backend.formatter
    -- local header    = type(backend.header) == 'function' and backend.header(data) or backend.header

    local function handle(output)
        local status, body = pcall(vim.json.decode, output.body)
        if not status or not body then
            data.result[name] = false
            return
        end

        data.result[name] = formatter(body, data)
    end

    Trans.curl[backend.method](backend.uri, {
        query = backend.get_query(data),
        callback = handle,
        --- FIXME :
        header = header,
    })
end

-- TODO :Implement all of utility functions
M.util = m_util


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
