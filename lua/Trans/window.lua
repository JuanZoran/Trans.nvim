local api = vim.api
--- =================== Window Attributes ================================
local M = {
    height     = 0, -- 窗口的当前的高度
    size       = 0, -- 窗口的行数
    width      = 0, -- 窗口的当前的宽度
    lines      = {},
    highlights = {},
    winid      = -1, -- 窗口的handle
    bufnr      = -1, -- 窗口对应的buffer的handle
    hl         = api.nvim_create_namespace('TransWinHl'),
}

-- M.<++>   --> <++>

function string:width()
    ---@diagnostic disable-next-line: param-type-mismatch
    return vim.fn.strwidth(self)
end

--- =================== Load Window Options ================================
M.init = function(entry, opts)
    vim.validate {
        entry = { entry, 'b' },
        opts = { opts, 't' }
    }
    local opt = {
       relative  = nil,
        width     = nil,
        height    = nil,
        border    = nil,
        title     = nil,
        col       = nil,
        row       = nil,
        title_pos = 'center',
        focusable = false,
        zindex    = 100,
        style     = 'minimal',
    }

    for k, v in pairs(opts) do
        opt[k] = v
    end

    M.height = opt.height
    M.width  = opt.width
    M.bufnr  = api.nvim_create_buf(false, true)
    M.winid  = api.nvim_open_win(M.bufnr, entry, opt)
    M.set('winhl', 'Normal:TransWin,FloatBorder:TransBorder')
    M.bufset('bufhidden', 'wipe')
    M.bufset('filetype', 'Trans')
    M.wipe()
end


M.draw = function()
    -- TODO :
    M.bufset('modifiable', true)
    api.nvim_buf_set_lines(M.bufnr, 0, -1, false, M.lines)
    for _, hl in ipairs(M.highlights) do
        api.nvim_buf_add_highlight(M.bufnr, M.hl, hl.name, hl.line, hl._start, hl._end)
    end

    M.bufset('modifiable', false)
    -- vim.pretty_print(M.highlights)
end

---清空window的数据
M.wipe = function()
    M.size = 0
    local clear = require('table.clear')
    clear(M.lines)
    clear(M.highlights)
end

M.is_open = function()
    return M.winid > 0 and api.nvim_win_is_valid(M.winid)
end


---安全的关闭窗口
---@param interval integer 窗口关闭动画的间隔
M.try_close = function(interval)
    if M.is_open() then
        local function narrow()
            if M.height > 1 then
                M.height = M.height - 1
                api.nvim_win_set_height(M.winid, M.height)
                vim.defer_fn(narrow, interval)
            else
                -- Wait animation done
                vim.defer_fn(function()
                    api.nvim_win_close(M.winid, true)
                    M.winid = -1
                end, interval + 2)
            end
        end

        narrow()
    end
end


M.cur_height = function()
    if api.nvim_win_get_option(M.winid, 'wrap') then
        local height = 0
        local width = M.width
        local lines = M.lines

        for i = 1, M.size do
            height = height + math.max(1, (math.ceil(lines[i]:width() / width)))
        end
        return height

    else
        return M.size
    end
end


M.adjust = function()
    local cur_height = M.cur_height()
    if M.height > cur_height then
        api.nvim_win_set_height(M.winid, cur_height)
        M.height = cur_height
    end

    if M.size == 1 then
        api.nvim_win_set_width(M.winid, M.lines[1]:width())
    end
end


---- ============ Utility functions ============
---设置窗口选项
---@param option string 需要设置的窗口
---@param value any 需要设置的值
M.set = function(option, value)
    api.nvim_win_set_option(M.winid, option, value)
end

---设置窗口对应buffer的选项
---@param option string 需要设置的窗口
---@param value any 需要设置的值
M.bufset = function(option, value)
    api.nvim_buf_set_option(M.bufnr, option, value)
end


M.normal = function(key)
    api.nvim_buf_call(M.bufnr, function()
        vim.cmd([[normal! ]] .. key)
    end)
end

---设置该窗口的本地的键映射(都为normal模式)
---@param key string 映射的键
---@param operation any 执行的操作
M.map = function(key, operation)
    -- api.nvim_buf_set_keymap(M.bufnr, 'n', key, operation, { silent = true, noremap = true, })
    vim.keymap.set('n', key, operation, {
        silent = true,
        buffer = M.bufnr,
    })
end


--- =================== Window lines ================================
local function insert_line(text)
    vim.validate {
        text = { text, 's' },
    }

    M.size = M.size + 1
    M.lines[M.size] = text
end


---向窗口中添加新行
---@param newline string 待添加的新行
---@param opt? table|string 可选的行属性: highlight, TODO :
M.addline = function(newline, opt)
    insert_line(newline)

    if type(opt) == 'string' then
        table.insert(M.highlights, {
            name = opt,
            line = M.size - 1, -- NOTE : 高亮的行号是以0为第一行
            _start = 0,
            _end = -1,
        })
        -- elseif type(opt) == 'table' then
        --     -- TODO :
        --     error('TODO')
    end
end

---添加一行新的内容并居中
---@param text string 需要居中的文本
---@param highlight? string 可选的高亮组
M.center = function(text, highlight)
    vim.validate {
        text = { text, 's' }
    }
    local space = math.floor((M.width - text:width()) / 2)
    local interval = (' '):rep(space)
    insert_line(interval .. text)
    if highlight then
        table.insert(M.highlights, {
            name = highlight,
            line = M.size - 1,
            _start = space,
            _end = space + #text,
        })
    end
end


---返回一个行的包装器: 具有 [add_item] [load] 方法
---能够添加item, 调用load格式化并载入window.lines
M.line_wrap = function()
    local items = {}
    local width = 0 -- 所有item的总width
    local size  = 0 -- item数目
    return {
        add_item = function(item, highlight)
            size = size + 1
            items[size] = { item, highlight }
            width = width + item:width()
        end,

        load = function()
            assert(size > 1, 'no item need be loaded')
            local space = math.floor((M.width - width) / (size - 1))
            assert(space > 0, 'try to expand window width')
            local interval = (' '):rep(space)
            local value = ''
            local function load_item(idx)
                local item = items[idx]
                if item[2] then
                    table.insert(M.highlights, {
                        name = item[2],
                        line = M.size, -- NOTE : 此时还没插入新行, size ==> 行号(zero index)
                        _start = #value,
                        _end = #value + #item[1],
                    })
                end
                value = value .. item[1]
            end

            load_item(1)
            for i = 2, size do
                value = value .. interval
                load_item(i)
            end

            insert_line(value)
        end
    }
end



M.text_wrap = function()
    insert_line('')
    local l = M.size

    return function(text, highlight)
        if highlight then
            local _start = #M.lines[l]
            local _end = _start + #text
            table.insert(M.highlights, {
                name = highlight,
                line = M.size - 1,
                _start = _start,
                _end = _end,
            })
        end

        M.lines[l] = M.lines[l] .. text
    end
end



--- =================== Window Highlights ================================
--- TODO : add helpful function for highlights

return M
