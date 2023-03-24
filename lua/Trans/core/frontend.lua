local Trans = require 'Trans'
local conf = Trans.conf
local frontend_opts = conf.frontend


---@class TransFrontend
---@field opts TransFrontendOpts
---@field get_active_instance fun():TransFrontend?
---@field process fun(self: TransFrontend, data: TransData)
---@field wait fun(self: TransFrontend): fun() Update wait status
---@field execute fun(action: string) @Execute action for frontend instance
---@field fallback fun() @Fallback method when no result
---@field setup? fun() @Setup method for frontend [optional] **NOTE: This method will be called when frontend is first used**

---@class Trans
---@field frontend TransFrontend
return setmetatable({}, {
    __index = function(self, name)
        local opts = vim.tbl_extend('keep', frontend_opts[name] or {}, frontend_opts.default)

        ---@type TransFrontend
        local frontend = require('Trans.frontend.' .. name)

        frontend.opts = opts
        self[name] = frontend

        if frontend.setup then
            frontend.setup()
        end
        return frontend
    end,
})
