local type_check = require("Trans.util.debug").type_check

local window = require("Trans.conf.window")
-- Default conf
local core = require("Trasn.core")

local function get_opts(opts)
    local default_conf = {
        method = vim.api.nvim_get_mode(),
        engine = {
            'local',
            -- TODO : other engine
        },
        win = window.cursor_win,
    }

    -- TODO :process win height and width
    if type(opts.engine) == 'string' then
        opts.engine = { opts.engine }
    end

    if opts.win then
        opts.win = window.process(opts.win)
    end
    return vim.tbl_extend('force', default_conf, opts)
end

local function translate(opts)
    type_check {
        opts = { opts, 'table' }
    }
    opts = get_opts(opts or {})


    local field = core.query(opts)

    opts = {
        field = field,
    }

    local content = core.process(opts)

    opts = {
        style = opts.style,
        height = opts.height,
        width = opts.width,
        content = content,
    }
    core.show(opts)
end

return translate
