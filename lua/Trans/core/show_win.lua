local type_check = require("Trans.util.debug").type_check

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
        border = { opts.border, 'string' },
        highlight = { opts.highlight, 'table', true },
    }

    local is_float = opts.style == 'float'
    local win_opts = {
        relative = opts.style == 'float' and 'editor' or 'cursor',
        width = opts.width,
        height = opts.height,
        style = 'minimal',
        border = opts.border,
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

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, opts.lines)

    for line, l_hl in ipairs(opts.highlight) do
        for i, hl in ipairs(l_hl) do
            vim.api.nvim_buf_add_highlight(bufnr, line, hl.name, i, hl._start, hl._end)
        end
    end

    return bufnr, winid
end

return show_win
