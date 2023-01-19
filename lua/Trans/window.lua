local M   = {}
local api = vim.api
-- local conf = require('Trans').conf
--- =================== Window Attributes ================================
-- M.height --> 窗口的高度
-- M.size   --> 窗口的行数
-- M.width  --> 窗口的宽度
-- M.winid  --> 窗口的handle
-- M.bufnr  --> 窗口对应的buffer的handle
M.bufnr   = api.nvim_create_buf(false, true)
M.hl      = api.nvim_create_namespace('TransWinHl')
-- M.<++>   --> <++>

api.nvim_buf_set_option(M.bufnr, 'filetype', 'Trans')

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
    M.winid  = api.nvim_open_win(M.bufnr, entry, opt)
    M.set('winhl', 'Normal:TransWin,FloatBorder:TransBorder')
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

M.try_close = function()
    if M.is_open() then
        local function narrow()
            if M.height > 1 then
                M.height = M.height - 1
                api.nvim_win_set_height(M.winid, M.height)
                vim.defer_fn(narrow, 13)
            else
                -- Wait animation done
                vim.defer_fn(function()
                    api.nvim_win_close(M.winid, true)
                end, 15)
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


--- =================== Window lines ================================
M.lines = {}


---- ============ Utility functions ============
local function insert_line(text)
    vim.validate {
        text = { text, 's' },
    }

    M.size = M.size + 1
    M.lines[M.size] = text
end

local function current_line_index()
    return M.size - 1
end

---向窗口中添加新行
---@param newline string 待添加的新行
---@param opt? table|string 可选的行属性: highlight, TODO :
M.addline = function(newline, opt)
    insert_line(newline)

    if type(opt) == 'string' then
        table.insert(M.highlights, {
            name = opt,
            line = current_line_index(), -- NOTE : 高亮的行号是以0为第一行
            _start = 0,
            _end = -1,
        })
    elseif type(opt) == 'table' then
        -- TODO :
        error('TODO')
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
                        line = current_line_index() + 1,
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
                line = current_line_index(),
                _start = _start,
                _end = _end,
            })
        end

        M.lines[l] = M.lines[l] .. text
    end
end


--- =================== Window Highlights ================================
M.highlights = {}

--- TODO : add helpful function for highlights

return M
