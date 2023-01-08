local M = {}
-- local type_check = require("Trans.util.debug").type_check


-- NOTE :中文字符及占两个字节宽，但是在lua里是3个字节长度
-- 为了解决中文字符在lua的长度和neovim显示不一致的问题
function string:width()
    return vim.fn.strdisplaywidth(self)
end

-- 各种风格的基础宽度
local style_width = {
    -- float = require("Trans.conf.window").float.width, -- NOTE : need window parsed conf
    cursor = 60,
}
local s_to_b = true -- 从小到大排列

local m_fields     -- 待格式化的字段
local m_indent     -- 每行的行首缩进
local m_tot_width     -- 所有字段加起来的长度(不包括缩进和间隔)
local m_interval   -- 每个字段的间隔
local m_win_width  -- 需要被格式化窗口的高度
local m_item_width -- 每个字段的宽度
local m_size

local function caculate_format()
    local width = m_win_width - m_item_width[1]
    local cols = 0
    for i = 2, #m_fields do
        width = width - m_item_width[i] - m_interval
        if width < 0 then
            cols = i - 1
            break
        else
            cols = i
        end
    end

    return math.ceil(#m_fields / cols), cols
end

local function format_to_line()
    local line = m_fields[1]
    if m_size == 1 then
        --- Center Align
        local space = math.floor((m_win_width - m_item_width[1]) / 2)
        line = (' '):rep(space) .. line
    else
        local space = math.floor((m_win_width - m_tot_width) / m_size - 1)
        for i = 2, m_size do
            line = line .. (' '):rep(space) .. m_fields[i]
        end
    end
    return line
end


local function sort_tables()
    table.sort(m_item_width, function (a, b)
        return a > b
    end)

    table.sort(m_fields, function (a, b)
        return a:width() > b:width()
    end)
end


local function format_to_multilines()
    local lines = {}
    sort_tables()

    --- NOTE ： 计算应该格式化成多少行和列
    local rows, cols = caculate_format()
    local rest = #m_fields % cols
    if rest == 0 then
        rest = cols
    end

    local s_width = m_item_width[1] -- 列中最宽的字符串宽度
    -- NOTE : 第一列不需要加空格
    for i = 1, rows do
        local idx = s_to_b and rows - i + 1 or i
        local space = (' '):rep(s_width - m_item_width[i])
        lines[idx] = m_fields[i] .. space -- NOTE  由大到小
    end

    local index = rows + 1                 -- 最宽字符的下标
    local interval = (' '):rep(m_interval) -- 每个字符串间的间隙

    for j = 2, cols do -- 以列为单位遍历
        s_width = m_item_width[index]
        local stop = (j > rest and rows - 1 or rows)
        for i = 1, stop do
            local idx   = s_to_b and stop - i + 1 or i            -- 当前操作的行数
            local item  = index + i - 1                           -- 当前操作的字段数
            local space = (' '):rep(s_width - m_item_width[item]) -- 对齐空格

            lines[idx] = lines[idx] .. interval .. m_fields[item] .. space -- NOTE  从大到小
        end
        index = index + stop -- 更新最宽字符的下标
    end

    return lines
end


local function get_formatted_lines()
    local lines = {}
    -- NOTE : 判断能否格式化成一行
    local line_size = m_tot_width + (#m_fields * m_interval)
    if line_size > m_win_width then
        lines = format_to_multilines()
    else
        lines[1] = format_to_line()
    end

    -- NOTE :进行缩进
    if m_indent > 0 then
        for i, v in ipairs(lines) do
            lines[i] = (' '):rep(m_indent) .. v
        end
    end
    return lines
end

---将组件格式化成相应的vim支持的lines格式
---@param style string 窗口的风格
---@param fields string[] 需要格式化的字段
---@param indent? number 缩进的长度
---@return string[] lines 便于vim.api.nvim_buf_set_lines
M.to_lines = function(style, fields, indent)

    local length = 0
    local width = 0
    local item_size = {}
    for i, v in ipairs(fields) do
        width = v:width()
        item_size[i] = width
        length = length + width
    end

    m_indent = indent or 0
    m_win_width  = style_width[style] - m_indent
    m_fields = fields
    m_tot_width = length
    m_item_width = item_size
    m_interval = m_win_width > 50 and 6 or 4
    m_size = #fields

    return get_formatted_lines()
end

local test = {
    'isjlk测试dj',
    '测试一下..',
}

local lines = M.to_lines('cursor', test)

-- print('===========================================')
-- for _, v in ipairs(test) do
--     print(v .. '                width:', v:width())
-- end
-- print('===========================================')
-- print('===========================================')
-- print('===========================================')

-- print('type is :' .. type(lines) .. '  size is :' .. #lines[1])

for _, v in ipairs(test) do
    print(v:width())
end

-- lines = M.to_lines('cursor', {
--     'ajlkasj',
--     'jklasjldajjnn测试',
--     '测试将安得拉蓝色',
--     'cool this',
-- }, 4)

-- for _, v in ipairs(lines) do
--     print(v)
-- end
return M

