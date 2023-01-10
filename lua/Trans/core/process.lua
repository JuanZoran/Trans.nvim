local type_check = require("Trans.util.debug").type_check

-- NOTE :中文字符及占两个字节宽，但是在lua里是3个字节长度
-- 为了解决中文字符在lua的长度和neovim显示不一致的问题
local function get_width(str)
    if type(str) ~= 'string' then
        vim.pretty_print(str)
        error('str!')
    end
    return vim.fn.strdisplaywidth(str)
end

local function format(win_width, items)
    table.sort(items, function(a, b)
        local wa, wb = 0, 0
        if type(a) == 'string' then
            wa = get_width(a)
            a = { a }
        else
            wa = get_width(a[1])
        end
        if type(b) == 'string' then
            wb = get_width(b)
            b = { b }
        else
            wb = get_width(b[1])
        end
        return wa > wb
    end)

    local size = #items
    local width = win_width - get_width(items[1][1])
    local cols = 0
    for i = 2, size do
        width = width - 4 - get_width(items[i][1])
        if width < 0 then
            cols = i
            break
        end
    end


    if cols == 0 then
        return items
    else
        local lines = {}
        local rows = math.floor(size / cols)
        local rest = size % cols
        if rest == 0 then
            rest = cols
        end

        local max_width = get_width(items[1][1])
        for i = 1, rows do
            local index = rows - i + 1
            lines[index] = {
                interval = items.interval,
                highlight = items.highlight,
                indent = items.indent,
            }

            items[i][1] = items[i][1] .. (' '):rep(max_width - get_width(items[i][1]))
            lines[index][1] = items[i]
        end

        local index = rows + 1
        for col = 2, cols do
            max_width = get_width(items[index])
            local _end = col > rest and rows - 1 or rows

            for i = 1, _end do
                local idx = _end - i + 1 -- 当前操作的行数
                local item_idx = index + i - 1
                local item = items[item_idx]
                item[1] = item[1] .. (' '):rep(max_width - get_width(item[1]))


                lines[idx][col] = item
            end
            index = index + _end
        end

        return lines
    end
end


local function process(opts)
    type_check {
        opts            = { opts, 'table' },
        ['opts.field']  = { opts.field, 'table', true },
        ['opts.order']  = { opts.order, 'table' },
        ['opts.win']  = { opts.win, 'table' },
        ['opts.engine'] = { opts.engine, 'table' },
    }

    if opts.field == nil then
        local lines = {'no tranlation'}
        vim.api.nvim_buf_set_lines(opts.bufnr, 0, -1, false, lines)
        return
    end


    local content = require('Trans.component.content'):new()

    for _, v in ipairs(opts.order) do
        local component = require("Trans.component." .. 'offline' --[[ opts.engine ]] .. '.' .. v).component(opts.field)
        -- vim.pretty_print(component)

        for _, items in ipairs(component) do
            local formatted_items, split = format(opts.win.width, items)
            if split then
                for _, itms in ipairs(formatted_items) do
                    content:insert(itms)
                end
            else
                content:insert(formatted_items)
            end
        end
    end

    local lines, __highlight = content:data()
    vim.api.nvim_buf_set_lines(opts.bufnr, 0, -1, false, lines)


    for line, l_hl in ipairs(__highlight) do
        for _, hl in ipairs(l_hl) do
            vim.api.nvim_buf_add_highlight(opts.bufnr, -1, hl.name, line, hl._start, hl._end)
        end
    end
    vim.api.nvim_buf_set_option(opts.bufnr, 'modifiable', false)
    vim.api.nvim_buf_set_option(opts.bufnr, 'filetype', 'Trans')
    if opts.win.style == 'cursor' then
        vim.api.nvim_create_autocmd(
            { 'InsertEnter', 'CursorMoved', 'BufLeave', }, {
            buffer = 0,
            once = true,
            callback = function ()
                vim.api.nvim_win_close(opts.winid, true)
            end,
        })
    end
end

return process
