_G.Trans = require 'Trans'
local node = Trans.util.node
_G.i, _G.t, _G.pr, _G.f = node.item, node.text, node.prompt, node.format

_G.api = vim.api
_G.fn = vim.fn
_G.mock = require 'luassert.mock'
_G.stub = require 'luassert.stub'

---@param func fun(buffer: TransBuffer)
---@return fun()
function _G.with_buffer(func)
    return function()
        local buffer = Trans.buffer.new()
        func(buffer)
        buffer:destroy()
    end
end
