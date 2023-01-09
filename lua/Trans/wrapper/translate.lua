local type_check = require("Trans.util.debug").type_check
-- Default conf
local conf = require("Trans.conf.loader").loaded_conf
local core = require("Trasn.core")


local function get_opts(opts)
    local default_conf = {
        method = vim.api.nvim_get_mode(),
        engine = {
            'local',
            -- TODO : other engine
        },
        win = {
            style = 'cursor',
            width = conf.window.cursor.width,
            height = conf.window.cursor.height
        },
    }

    if type(opts.engine) == 'string' then
        opts.engine = { opts.engine }
    end

    if opts.win then
        local width, height = opts.win.width, opts.win.height
        if width and width > 0 and width <= 1 then
            opts.win.width = math.floor(vim.o.columns * width)
        end

        if height and height > 0 and height <= 1 then
            opts.win.height = math.floor(vim.o.lines * opts.win.height)
        end
    end

    return vim.tbl_extend('force', default_conf, opts)
end

local function translate(opts)
    type_check {
        opts = { opts, 'table' }
    }

    --- TODO : 异步请求
    -- NOTE : 这里只处理了本地的请求
    opts = get_opts(opts or {})
    local field = core.query(opts)

    local proc_opts = {
        field = field,
        order = conf.order['offline'],
        engine = 'offline',
        win_style = opts.win.style,
    }

    local content, highlight = core.process(proc_opts)

    local win_opts = {
        win = opts.win,
        content = content,
        highlight = highlight,
    }

    core.show_win(win_opts)
end

return translate
