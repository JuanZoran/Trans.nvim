local type_check = require("Trans.util.debug").type_check

-- NOTE :中文字符及占两个字节宽，但是在lua里是3个字节长度
-- 为了解决中文字符在lua的长度和neovim显示不一致的问题
local get_width = vim.fn.strdisplaywidth

local function format(win_width, items)
    local size = #items
    local tot_width = 0

    for i = 1, size do
        if type(items[i]) == 'string' then
            items[i] = { items[i] }
        end
        tot_width = tot_width + get_width(items[i][1]) + 4
    end


    -- 判断宽度是否超过最大宽度
    if tot_width > win_width + 4 then
        -- 放不下则需要分成多行
        local lines = {}

        -- 行内字符串按照宽度排序
        table.sort(items, function(a, b)
            return get_width(a[1]) > get_width(b[1])
        end)

        local cols = 1
        win_width = win_width - get_width(items[1][1])
        while win_width > 0 and cols < size do
            cols = cols + 1
            win_width = win_width - get_width(items[cols][1]) + 4
        end
        cols = cols - 1

        local rows = math.ceil(size / cols)
        local rest = size % cols
        if rest == 0 then
            rest = cols
        end
        local max_width = get_width(items[1][1])
        local index = 1 -- 当前操作的字符串下标
        for i = rows, 1, -1 do -- 当前操作的行号
            lines[i] = {
                highlight = items.highlight,
                indent = items.indent,
            }

            local item = items[index]
            item[1] = item[1] .. (' '):rep(max_width - get_width(item[1]))
            lines[i][1] = items[index]
            index = index + 1
        end


        for col = 2, cols do
            max_width = get_width(items[index][1])
            local _end = col > rest and rows - 1 or rows

            for i = _end, 1, -1 do
                local item = items[index]
                item[1] = item[1] .. (' '):rep(max_width - get_width(item[1]))


                lines[i][col] = item
                index = index + 1
            end
        end

        return lines, true
    else
        return items
    end
end

local function process(opts)
    type_check {
        opts            = { opts, 'table' },
        ['opts.field']  = { opts.field, 'table', true },
        ['opts.order']  = { opts.order, 'table' },
        ['opts.win']    = { opts.win, 'table' },
        ['opts.engine'] = { opts.engine, 'table' },
    }

    if opts.field == nil then
        local lines = { '⚠️   本地没有找到相关释义' }
        vim.api.nvim_buf_set_lines(opts.bufnr, 0, -1, false, lines)
        vim.api.nvim_win_set_height(opts.winid, 1)
        vim.api.nvim_win_set_width(opts.winid, get_width(lines[1]))

    else
        local content = require('Trans.component.content'):new()
        for _, v in ipairs(opts.order) do
            local component = require("Trans.component." .. 'offline' --[[ opts.engine ]] .. '.' .. v).component(opts.field)
            if component then
                for _, items in ipairs(component) do

                    if items.needformat then
                        local formatted_items, split = format(opts.win.width, items)
                        if split then
                            for _, itms in ipairs(formatted_items) do
                                content:insert(itms)
                            end
                        else
                            content:insert(formatted_items)
                        end

                    else
                        content:insert(items)
                    end

                end
            end

        end

        content:attach(opts.bufnr, opts.winid)

    end

    vim.api.nvim_buf_set_option(opts.bufnr, 'modifiable', false)
    vim.api.nvim_buf_set_option(opts.bufnr, 'filetype', 'Trans')

    vim.api.nvim_win_set_option(opts.winid, 'winhl', 'Normal:TransCursorWin,FloatBorder:TransCursorBorder')
    if opts.win.style == 'cursor' then
        vim.api.nvim_create_autocmd(
            { 'InsertEnter', 'CursorMoved', 'BufLeave', }, {
            buffer = 0,
            once = true,
            callback = function()
                if vim.api.nvim_win_is_valid(opts.winid) then
                    vim.api.nvim_win_close(opts.winid, true)
                end
            end,
        })
    end
end

return process
