local M = {}
M.__index = M

M.get_width = vim.fn.strwidth


---@alias block table add_hl(key, hl_name)
---返回分配的块状区域, e_col 设置为-1则为末尾
---@param s_row integer 起始行
---@param s_col integer 起始列
---@param height integer 行数
---@param width integer 块的宽度
---@return block
function M:alloc_block(s_row, s_col, height, width)
    -- -1为到行尾
    width = width == -1 and self.width or width
    local e_col = s_col + width

    local block = {
        add_hl = function(key, hl_name)
            table.insert(self.highlight[s_row + key], {
                name = hl_name,
                _start = s_col,
                _end = e_col,
            })
        end
    }

    return setmetatable(block, {
        -- 访问该表的操作, 映射成lines
        __index = function(_, key)
            assert(0 < key and key <= height)
            --- FIXME : Unicode stirng sub
            return self.lines[s_row + key]:sub(s_col, e_col)
        end,

        __newindex = function(_, key, value)
            assert(0 < key and key <= height)
            local wid = self.get_width(value)
            if wid > width then
                error('check out the str width: Max ->' .. self.width .. ' str ->' .. wid)
            else
                value = value .. (' '):rep(width - wid)
            end

            local line = s_row + key - 1
            self.lines[line] = self.lines[line]:sub(1, s_col - 1) .. value .. self.lines[line]:sub(e_col + 1)
        end,
    })
end


function M:alloc_items()
    local items = {}
    local width = 0 -- 所有item的总width
    local size  = 0 -- item数目
    return {
        add_item = function(item, highlight)
            size = size + 1
            local wid = self.get_width(item)
            items[size] = { item, highlight }
            width = width + wid
        end,

        load = function()
            local l = self.len + 1
            local space = math.floor((self.width - width) / (size - 1))
            assert(space > 0)
            local interval = (' '):rep(space)
            local value = ''
            local function load_item(index)
                if items[index][2] then
                    table.insert(self.highlights[l], {
                        name = items[index][2],
                        _start = #value,
                        _end = #value + #items[index][1],
                    })
                end
                value = value .. items[index][1]
            end

            load_item(1)
            for i = 2, size do
                value = value .. interval
                load_item(i)
            end

            self.lines[l] = value
            self.len = l
        end
    }
end

---返回新行的包装函数
---@return function
function M:text_wrapper()
    local l = self.len + 1 -- 取出当前行
    self.lines[l] = ''
    self.len = l
    return function(text, highlight)
        if highlight then
            local _start = #self.lines[l]
            local _end = _start + #text
            table.insert(self.highlights[l], {
                name = highlight,
                _start = _start,
                _end = _end,
            })
        end
        self.lines[l] = self.lines[l] .. text
    end
end

function M:addline(text, highlight)
    assert(text, 'empty text')
    self.len = self.len + 1
    if highlight then
        table.insert(self.highlights[self.len], {
            name = highlight,
            _start = 0,
            _end = -1
        })
    end
    self.lines[self.len] = text
end

function M:new(width)
    vim.validate {
        width = { width, 'n' }
    }

    local default = (' '):rep(width) -- default value is empty line
    local new_content = {
        width = width,
        len = 0,
        highlights = setmetatable({}, { -- always has default value
            __index = function(tbl, key)
                tbl[key] = {}
                return tbl[key]
            end
        }),
    }

    new_content.lines = setmetatable({}, {
        __index = function(tbl, key)
            tbl[key] = default
            return tbl[key]
        end,

        __newindex = function(tbl, key, value)
            assert(value, 'add no value as new line')
            for i = new_content.len + 1, key - 1 do
                rawset(tbl, i, '')
            end
            rawset(tbl, key, value)

            new_content.len = key
        end
    })

    return setmetatable(new_content, M)
end

function M:clear()
    require('table.clear')(self)
end

return M
