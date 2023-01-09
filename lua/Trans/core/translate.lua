-- Default conf
local conf = require("Trans.conf.loader").loaded_conf
local core = require("Trans.core")


local function get_opts(opts)
    local default_conf = {
        method = vim.api.nvim_get_mode().mode,
        engine = {
            'local',
            -- TODO : other engine
        },
        win = {
            style = 'cursor',
            width = conf.style.window.cursor.width,
            height = conf.style.window.cursor.height
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

-- EXAMPLE :
-- require('Trans').translate({
--     method = 'input', -- 不填则自动判断mode获取查询的单词
--     engine = { -- 异步查询所有的引擎, 按照列表
--         'offline',
--         'youdao',
--         'baidu'
--     },
--     -- win = 'cursor'
--     win = {
--         style = 'cursor',
--         height = 50,
--         width = 30,
--     }
-- })


local function create_win(opts)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, 'filetype', 'Trans')
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)

    local is_float = opts.style == 'float'
    local win_opts = {
        relative = is_float and 'editor' or 'cursor',
        width = opts.width,
        height = opts.height,
        style = 'minimal',
        border = conf.style.window[opts.win.style].border,
        title = 'Trans',
        title_pos = 'center',
        focusable = true,
        zindex = 100,
    }

    if is_float then
        win_opts.row = math.floor((vim.o.lines - win_opts.height - vim.o.cmdheight) / 2)
        win_opts.col = math.floor((vim.o.columns - win_opts.width) / 2)
    else
        win_opts.row = 2
        win_opts.col = 2
    end

    local winid = vim.api.nvim_open_win(bufnr, is_float, win_opts)

    return bufnr, winid
end

local function translate(opts)
    vim.validate {
        opts = { opts, 'table', true }
    }

    --- TODO : 异步请求
    -- NOTE : 这里只处理了本地数据库查询
    opts = get_opts(opts or {})
    local field = core.query(opts)

    local bufnr, winid = create_win(opts.win)

    local proc_opts = {
        bufnr = bufnr,
        winid = winid,
        field = field,
        order = conf.order['offline'],
        engine = { 'offline' },
        win_opts = opts.win,
    }

    core.process(proc_opts)
end

return translate
