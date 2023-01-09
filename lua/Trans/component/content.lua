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

-- NOTE :
-- local items = {
--     -- style1: string 不需要单独设置高亮的情况
--     'text',
--     -- style2: string[] 需要设置高亮，第二个名称为高亮组
--     {'text2', 'highlight name'},
-- }

-- local opts = {
--     -- 可选的参数
--     highlight = 'highlight name' -- string 该行的高亮
--     indent = 4 -- integer 该行的应该在开头的缩进
--     interval = 4 -- integer 该行组件的间隔
-- }
function M:insert(items)
    type_check {
        items = { items, 'table' },
    }

    self.size = self.size + 1 -- line数加一

    local line = {
        space = (' '):rep(items.interval),
        indent = items.indent,
        highlight = items.highlight,
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

---Usage:
---     local buffer_id
---     local lines, highlights = M:lines()
---     vim.api.nvim_buf_set_lines(buffer_id, 0, -1, false,lines)
---     for i, hl in ipairs(highlights) do
---         vim.api.nvim_buf_add_highlight(buffer_id, 0, hl.name, i, hl._start, hl._end)
---     end
---@return table line
---@return table highlight
function M:data()
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
                    local _end = #line
                    table.insert(highlight, { name = hl[i], _start = _end - #l[i], _end = _end })
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
