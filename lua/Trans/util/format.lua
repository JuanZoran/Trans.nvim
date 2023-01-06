---@diagnostic disable: undefined-global
local M = {}
local type_check = require("Trans.util.debug").type_check

-- 各种风格的基础宽度
local style_width = {
    float = require("Trans.conf.window").float.width, -- NOTE : need window parsed conf
    cursor = require("Trans.conf.window").cursor.width,
}

local m_width  = nil -- 需要被格式化窗口的高度
local m_fields = nil -- 待格式化的字段
local m_indent = nil -- 每行的行首缩进
local m_length = nil -- 所有字段加起来的长度(不包括缩进和间隔)

local function get_rows()
    -- TODO
    return rows
end

local function do_indent(lines)
    for i, v in ipairs(lines) do
        lines[i] = (' '):rep(m_indent) .. v
    end
end

local function format_to_line()
    local space = math.floor((m_width - m_length) / #m_fields)
    return line
end

local function format_to_multilines()
    -- TODO
    type_check {
        interval = { interval, 'number' },
        rows     = { rows, 'number' },
    }
end

local function get_formatted_lines()
    local lines = {}
    -- NOTE : 判断能否格式化成一行
    if m_length + (#m_fields * m_indent) > m_width then
        lines = format_to_multilines()
    else
        lines[1] = format_to_line()
    end

    if m_indent then
        do_indent(lines)
    end
    return lines
end

---将组件格式化成相应的vim支持的lines格式
---@param style string 窗口的风格
---@param fields string[] 需要格式化的字段
---@param indent number 缩进的长度
---@return string[] lines 便于vim.api.nvim_buf_set_lines
M.to_lines = function(style, fields, indent)
    if not fields then
        return {}
    end
    type_check {
        style = { style, { 'string' } },
        fields = { fields, { 'table' } },
        indent = { indent, { 'number' }, true },
    }

    local length = 0
    for _, v in ipairs(fields) do
        length = length + #v
    end

    m_width      = style_width[style] - indent
    m_indent     = indent
    m_fields = fields
    m_length = length
    return get_formatted_lines()
end

-- local function get_lines(win_width, components)
--     local lines = {}
--     local interval = win_width > 40 and 6 or 4
--     local row = 1
--     local width = win_width - #components[1]
--     for i in 2, #components do
--         width = width - #components[i] - interval
--         if width < 0 then
--             width = win_width - #components[i]
--             row = row + 1
--         end
--     end
--     if row == 1 then
--         local format = '%s' .. ((' '):rep(interval) .. '%s')
--         lines[1] = string.format(format, unpack(components))
--     else
--         table.sort(components, function (a, b)
--             return #a > #b
--         end)
--         -- FIXME
--         local res, rem = #components / (row + 1), #components % (row + 1)
--         row = math.ceil(res)
--         local rol = row - rem - 1
--     end
--
--     return lines
-- end
--
-- M.format = function(style, components, indent)
--     local lines = {}
--     if #components > 1 then
--         indent = indent or 0
--         type_check {
--             style = { style, 'string' },
--             components = { components, 'table' }, ---@string[]
--             -- max_items = { max_items, { 'nil', 'number' } }, ---@string[]
--         }
--         local win_width = (style == 'float' and float_win_width or cursor_win_width) - indent
--         local res = get_lines(win_width, components)
--     end
--     return lines
-- end
return M
