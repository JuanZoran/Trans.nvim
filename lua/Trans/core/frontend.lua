local Trans = require('Trans')
local conf = Trans.conf
local frontend_opts = conf.frontend


---Setup frontend Keymaps
---@param frontend TransFrontend
local function set_frontend_keymap(frontend)
    local set = vim.keymap.set
    local keymap_opts = {
        silent = true,
        -- expr = true,
        -- nowait = true,
    }

    for action, key in pairs(frontend.opts.keymaps) do
        set('n', key, function()
            local instance = frontend.get_active_instance()

            if instance then
                coroutine.wrap(instance.execute)(instance, action)
            else
                return key
            end
        end, keymap_opts)
    end
end


---@class TransFrontend
---@field opts TransFrontendOpts
---@field get_active_instance fun():TransFrontend?
---@field process fun(self: TransFrontend, data: TransData)
---@field wait fun(self: TransFrontend): fun() Update wait status
---@field execute fun(action: string) @Execute action for frontend instance
---@field fallback fun() @Fallback method when no result

---@class Trans
---@field frontend TransFrontend
return setmetatable({}, {
    __index = function(self, name)
        local opts = vim.tbl_extend('keep', frontend_opts[name] or {}, frontend_opts.default)

        ---@type TransFrontend
        local frontend = require('Trans.frontend.' .. name)

        frontend.opts = opts
        self[name] = frontend

        set_frontend_keymap(frontend)

        return frontend
    end
})
