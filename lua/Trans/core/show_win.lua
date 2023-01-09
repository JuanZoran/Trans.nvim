local type_check = require("Trans.util.debug").type_check

local buf_opts = {
    filetype = 'Trans',
    modifiable = false,
}

-- local win_opts = {
--     winhl = 'Normal:TransWinNormal, FloatBorder:TransWinBorder'
-- }

local function caculate_format(height, width)
    local col = math.floor((vim.o.lines - height - vim.o.cmdheight) / 2)
    local row = math.floor((vim.o.columns - width) / 2)
    return row, col
end

local function show_win(opts)
    type_check {
        opts = { opts, 'table' },
        win = { opts.win, 'table' },
        highlight = { opts.highlight, 'table', true },
    }

    local bufnr = vim.api.nvim_create_buf(false, true)
    for k, v in pairs(buf_opts) do
        vim.api.nvim_buf_set_option(bufnr, k, v)
    end

    local is_float = opts.style == 'float'
    local win_opts = {
        relative = opts.style == 'float' and 'editor' or 'cursor',
        width = opts.width,
        height = opts.height,
        style = 'minimal',
        border = 'rounded',
        title = 'Trans',
        title_pos = 'center',
        focusable = true,
        zindex = 100,
    }
    if is_float then
        win_opts.row, win_opts.col = caculate_format(win_opts.height, win_opts.width)
    else
        win_opts.row = 2
        win_opts.col = 2
    end
    local winid = vim.api.nvim_open_win(bufnr, is_float, win_opts)

    return bufnr, winid
end

return show_win
