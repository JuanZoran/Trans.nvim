local M = {}
M.__index = M

M.get_width = vim.fn.strdisplaywidth
-- local get_width = vim.fn.strwidth
-- local get_width = vim.api.nvim_strwidth

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
    local len = 0
    local size = 0
    return {
        add_item = function(item, highlight)
            size = size + 1
            local wid = self.get_width(item)
            items[size] = { item, highlight }
            len = len + wid
        end,

        load = function()
            self.len = self.len + 1
            local space = math.floor((self.width - len) / (size - 1))
            assert(space > 0)
            local interval = (' '):rep(space)
            local value = ''
            local function load_item(index)
                if items[index][2] then
                    local _start = #value
                    local _end = _start + #items[index][1]
                    table.insert(self.highlights[self.len], {
                        name = items[index][2],
                        _start = _start,
                        _end = _end
                    })
                end
                value = value .. items[index][1]
            end

            load_item(1)
            for i = 2, size do
                value = value .. interval
                load_item(i)
            end

            self.lines[self.len] = value
        end
    }
end

function M:alloc_text()
    local value = ''
    return {
        add_text = function(text, highlight)
            if highlight then
                local _start = #value
                local _end = _start + #text
                table.insert(self.highlights[self.len + 1], {
                    name = highlight,
                    _start = _start,
                    _end = _end,
                })
            end
            value = value .. text
        end,
        load = function ()
            self.len = self.len + 1
            self.lines[self.len] = value
        end
    }
end


function M:addline(text, highlight)
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

-- 窗口宽度
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
            if value then
                for _ = new_content.len + 1, key - 1 do
                    rawset(tbl, key, '')
                end

                rawset(tbl, key, value)
                new_content.len = key
            end
        end
    })
    return setmetatable(new_content, self)
end

return M
