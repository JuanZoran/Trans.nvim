local api = vim.api

local content = {
    newline = function(self, value)
        local index = self.size + 1
        self.size = index
        self.lines[index] = value
    end,

    newhl = function(self, opt)
        local index = self.hl_size + 1
        self.hl_size = index
        self.highlights[index] = opt
    end,

    wipe = function(self)
        local clear = require('table.clear')
        clear(self.lines)
        clear(self.highlights)
        self.size = 0
        self.hl_size = 0
    end,

    ---将内容连接上对应的窗口
    ---@param self table content对象
    ---@param offset integer 起始行
    attach = function(self, offset)
        if self.size == 0 then
            return
        end

        offset = offset or 0
        local win = self.window
        win:bufset('modifiable', true)
        --- NOTE : 使用-1 则需要按顺序设置
        api.nvim_buf_set_lines(win.bufnr, offset, -1, true, self.lines)

        local hl
        local highlights = self.highlights
        local method = api.nvim_buf_add_highlight
        for i = 1, self.hl_size do
            hl = highlights[i]
            method(win.bufnr, win.hl, hl.name, offset + hl.line, hl._start, hl._end)
        end
        win:bufset('modifiable', false)
    end,

    actual_height = function(self, wrap)
        wrap = wrap or self.window:option('wrap')
        if wrap then
            local height = 0
            local width = self.window.width
            local lines = self.lines
            for i = 1, self.size do
                height = height + math.max(1, (math.ceil(lines[i]:width() / width)))
            end
            return height

        else
            return self.size
        end
    end,

    format = function(self, opt)
        local win_width = opt.width or self.window.width
        local nodes = opt.nodes
        local size = #nodes
        assert(size > 1, 'check items size')
        local tot_width = 0
        local strs = {}
        local str
        for i = 1, size do
            str = nodes[i].text
            strs[i] = str
            tot_width = tot_width + str:width()
        end

        local space = math.floor(((win_width - tot_width) / (size - 1)))
        if opt.strict and space < 0 then
            return false
        end

        local interval = (' '):rep(space)
        return {
            text = table.concat(strs, interval),
            load_hl = function(_, content, line, col)
                for _, item in ipairs(nodes) do
                    item:load_hl(content, line, col)
                    col = col + #item.text + space
                end
            end
        }
    end,

    center = function(self, item)
        local text = item.text
        local space = bit.rshift(self.window.width - text:width(), 1)
        item.text = (' '):rep(space) .. text
        local load_hl = item.load_hl
        item.load_hl = function(this, content, line, col)
            load_hl(this, content, line, col + space)
        end
        return item
    end,

    addline = function(self, ...)
        local strs = {}
        local col = 0
        local str
        local line = self.size -- line is zero index

        for i, node in ipairs { ... } do
            str = node.text
            strs[i] = str
            node:load_hl(self, line, col)
            col = col + #str
        end
        self:newline(table.concat(strs))
    end
}

content.__index = content

---content的构造函数
---@param window table 链接的窗口
---@return table 构造好的content
return function(window)
    vim.validate {
        window = { window, 't' },
    }
    return setmetatable({
        window = window,
        size = 0,
        hl_size = 0,
        lines = {},
        highlights = {},
    }, content)
end