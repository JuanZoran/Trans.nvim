local Trans            = require 'Trans'

---@class TransFrontendOpts
local default_frontend = {
    auto_play = true,
    query     = 'fallback',
    border    = 'rounded',
    title     = vim.fn.has 'nvim-0.9' == 1 and {
        { '', 'TransTitleRound' },
        { ' Trans', 'TransTitle' },
        { '', 'TransTitleRound' },
    } or nil, -- need nvim-0.9+
    ---@type {open: string | boolean, close: string | boolean, interval: integer} Window Animation
    animation = {
        open = 'slid', -- 'fold', 'slid'
        close = 'slid',
        interval = 12,
    },
    timeout   = 2000, -- only for online backend query
}

if Trans.conf.frontend.default then
    default_frontend = vim.tbl_extend('force', default_frontend, Trans.conf.frontend.default)
end

local function empty_method(method)
    return function() error('Method [' .. method .. '] not implemented') end
end


---@class TransFrontend
---@field opts? TransFrontendOpts options which user can set
---@field get_active_instance fun():TransFrontend?
---@field wait fun(self: TransFrontend): fun(backend: TransBackend): boolean Update wait status
---@field execute fun(action: string) @Execute action for frontend instance
---@field setup? fun() @Setup method for frontend [optional] **NOTE: This method will be called when frontend is first used**
local M = {
    ---@type fun() @Fallback method when no result
    fallback = empty_method 'fallback',
    ---@type fun(self: TransFrontend, data: TransData) @render backend result
    process = empty_method 'process',
}





---@class Trans
---@field frontend TransFrontend
return setmetatable(M, {
    __index = function(self, name)
        ---@type TransFrontend
        local frontend = require('Trans.frontend.' .. name)

        frontend.opts =
            vim.tbl_extend('force', frontend.opts or {}, default_frontend, Trans.conf.frontend[name])

        if frontend.setup then
            frontend.setup()
        end

        rawset(self, name, frontend)
        return frontend
    end,
})
