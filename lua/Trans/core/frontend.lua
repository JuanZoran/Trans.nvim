local Trans = require('Trans')
local conf = Trans.conf
local frontend_opts = conf.frontend


local function set_frontend_keymap(frontend)
    local set = vim.keymap.set
    local keymap_opts = { silent = true, expr = true }

    for action, key in pairs(frontend.opts.keymap) do
        set('n', key, function()
            local instance = frontend.get_active_instance()

            if instance then
                instance:execute(action)
            else
                return key
            end
        end, keymap_opts)
    end
end


local M = setmetatable({}, {
    __index = function(self, name)
        local opts = vim.tbl_extend('keep', frontend_opts[name] or {}, frontend_opts.default)
        local frontend = require('Trans.frontend.' .. name)


        frontend.opts = opts
        self[name] = frontend

        set_frontend_keymap(frontend)

        return frontend
    end
})



return M
