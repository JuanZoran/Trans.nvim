local api = vim.api
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

    center_line = function(self, text, highlight)
        vim.validate {
            text = { text, 's' }
        }

        local space = math.floor((self.window.width - text:width()) / 2)
        local interval = (' '):rep(space)
        self:newline(interval .. text)
        if highlight then
            self:newhl {
                name   = highlight,
                line   = self.size - 1,
                _start = space,
                _end   = space + #text,
            }
        end
    end,

    wipe = function(self)
        local clear = require('table.clear')
        clear(self.lines)
        clear(self.highlights)
        self.size = 0
    end,

    ---将内容连接上对应的窗口
    ---@param self table content对象
    ---@param offset integer 起始行
    attach = function(self, offset)
        if self.size == 0 then
            return
        end

        self.window:bufset('modifiable', true)
        local window = self.window
        api.nvim_buf_set_lines(window.bufnr, offset, offset + 1, true, self.lines)

        for _, hl in ipairs(self.highlights) do
            api.nvim_buf_add_highlight(window.bufnr, window.hl, hl.name, offset + hl.line, hl._start, hl._end)
        end
        self.window:bufset('modifiable', false)
    end,

    actual_height = function(self, wrap)
        wrap = wrap or self.window:option('wrap')
        if  wrap then
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

    addline = function(self, newline, highlight)
        self:newline(newline)
        if highlight then
            self:newhl {
                name = highlight,
                line = self.size - 1,
                _start = 0,
                _end = -1,
            }
        end
    end,

    items_wrap = function(self)
        local items = {}
        local size = 0
        local width = 0

        return {
            add_item = function(item, highlight)
                size = size + 1
                items[size] = { item, highlight }
                width = width + item:width()
            end,

            load = function()
                assert(size > 1, 'no item need be loaded')
                local space = math.floor((self.window.width - width) / (size - 1))
                assert(space > 0, 'try to expand window width')
                local interval = (' '):rep(space)
                local line = ''

                local function load_item(idx)
                    local item = items[idx]
                    if item[2] then
                        self:newhl {
                            name = item[2],
                            line = self.size, -- NOTE : 此时还没插入新行, size ==> 行号(zero index)
                            _start = #line,
                            _end = #line + #item[1],
                        }
                    end
                    line = line .. item[1]
                end

                load_item(1)
                for i = 2, size do
                    line = line .. interval
                    load_item(i)
                end

                self:newline(line)
            end
        }
    end,

    line_wrap = function(self)
        self:newline('')
        local index = self.size
        return function(text, highlight)
            if highlight then
                local _start = #self.lines[index]
                local _end = _start + #text
                self:newhl {
                    name = highlight,
                    line = index - 1,
                    _start = _start,
                    _end = _end,
                }
            end

            self.lines[index] = self.lines[index] .. text
        end
    end
}


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
    }, { __index = content })
end
