local api = vim.api

local format_meta = {
    load_hl = function(self, content, line, col)
        local space = self.space
        for _, item in ipairs(self.items) do
            item:load_hl(content, line, col)
            col = col + #item.text + space
        end
    end
}

local content = {
    newline = function(self, value)
        if not self.modifiable then
            error('content can not add newline now')
        end

        self.size = self.size + 1
        self.lines[self.size] = value
    end,

    newhl = function(self, opt)
        if not self.modifiable then
            error('content can not add newline now')
        end

        self.hl_size = self.hl_size + 1
        self.highlights[self.hl_size] = opt
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
        self.window:bufset('modifiable', true)
        local window = self.window
        --- NOTE : 使用-1 则需要按顺序设置
        api.nvim_buf_set_lines(window.bufnr, offset, -1, true, self.lines)

        local hl
        for i = 1, self.hl_size do
            hl = self.highlights[i]
            api.nvim_buf_add_highlight(window.bufnr, window.hl, hl.name, offset + hl.line, hl._start, hl._end)
        end
        self.window:bufset('modifiable', false)
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
        local width = 0
        local strs = {}
        for i, node in ipairs(nodes) do
            local str = node.text
            strs[i] = str
            width = width + str:width()
        end

        local space = math.floor(((win_width - width) / (size - 1)))
        if opt.strict and space < 0 then
            return false
        end

        local interval = (' '):rep(space)
        return setmetatable({
            text = table.concat(strs, interval),
            items = nodes,
            space = space,
        }, { __index = format_meta })
    end,

    center = function(self, item)
        local space = bit.rshift(self.window.width - item.text:width(), 1)
        item.text = (' '):rep(space) .. item.text
        local load_hl = item.load_hl
        item.load_hl = function(this, content, line, col)
            load_hl(this, content, line, col + space)
        end

        return item
    end,

    addline = function(self, ...)
        local strs = {}
        local col = 0
        for i, node in ipairs { ... } do
            local str = node.text
            strs[i] = str
            node:load_hl(self, self.size, col)
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
        modifiable = true,
        window = window,
        size = 0,
        hl_size = 0,
        lines = {},
        highlights = {},
    }, content)
end
