local M = {}
local type_check = require("Trans.util.debug").type_check
M.__index = M
M.lines = {}
M.highlight = {}
M.size = 0


function M:new()
    local content = {}
    setmetatable(content, self)
    return content
end

--- NOTE :highlight 格式说明:
--- 1. 字符串


function M:insert_items_to_line(items, opts)
    type_check {
        items = { items, 'table' },
        opts = { opts, 'table', true },
    }
    self.size = self.size + 1 -- line数加一

    local line = {
        space = (' '):rep(opts.interval),
        indent = opts.indent,
        highlight = opts.highlight,
    }
    local highlight = {}


    for i, item in ipairs(items) do
        if type(item) == 'string' then
            item = { item }
        end
        line[i] = item[1]
        if item[2] then
            highlight[i] = item[2]
        end
    end

    self.highlight[self.size] = highlight
    self.lines[self.size] = line
end

---遍历lines和高亮的迭代器
---Usage:
---     local buffer_id
---     local lines, highlights = M:lines()
---     vim.api.nvim_buf_set_lines(buffer_id, 0, -1, false,lines)
---     for i, hl in ipairs(highlights) do
---         vim.api.nvim_buf_add_highlight(buffer_id, 0, hl.name, i, hl._start, hl._end)
---     end
---@return table line
---@return table highlight
function M:lines()
    -- NOTE 返回格式化的行，如果需要高亮，则第二个参数返回高亮
    local lines = {}
    local highlights = {}
    for index = 1, #self.lines do
        local line = ''
        local highlight = {}
        local l = self.lines[index]
        local hl = self.highlight[index]
        if l.indent then
            line = (' '):rep(l.indent)
        end
        if l.highlight then
            line = line .. table.concat(l, l.space)
            highlight[1] = { name = l.highlight, _start = 1, _end = -1 }
        else
            line = line .. l[1]

            if hl[1] then
                -- WARN :可能需要设置成字符串宽度!!!
                table.insert(highlight, { name = hl[1], _start = #line - #l[1], _end = #line })
            end

            for i = 2, #l do
                line = line .. l.space .. l[i]
                if hl[i] then
                    table.insert(highlight, { name = hl[i], _start = #line - #l[i], _end = #line })
                end
            end
        end

        -- return line, highlights
        lines[index] = line
        highlights[index] = highlight
    end
    return lines, highlights
end

return M
