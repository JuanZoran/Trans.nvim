local M = {}

local display = require("Trans").conf.display
local icon = require("Trans").conf.icon
local order = require("Trans").conf.order


local buf = vim.api.nvim_create_buf(false, true)
local win = 0
vim.api.nvim_buf_set_option(buf, 'filetype', 'Trans')


local function show_win(width, height)
    win = vim.api.nvim_open_win(buf, false, {
        relative = 'cursor',
        title = 'Trans',
        title_pos = 'center',
        style = display.style,
        col = display.offset_x,
        row = display.offset_y,
        width = width > display.max_width and display.max_width or width,
        height = height > display.max_height and display.max_height or height,
        border = display.border_style,
        focusable = true,
    })
    vim.api.nvim_win_set_option(win, 'wrap', display.wrap)
end

-- NOTE: title
local function get_title(text, query_res)
    local title = string.format('%s    [%s]    ', query_res.word, query_res.phonetic) ..
        (display.oxford and (query_res.oxford == 1 and icon.isOxford .. '    ' or icon.notOxford .. '    ') or '') ..
        ((display.collins_star and query_res.collins) and string.rep(icon.star, query_res.collins) or '')
    table.insert(text, title)
end

-- NOTE: tag
local function get_tag(text, query_res)
    if #query_res.tag > 0 then
        local tag = query_res.tag:gsub('zk', '中考'):gsub('gk', '高考'):gsub('ky', '考研'):gsub('cet4', '四级'):
            gsub('cet6', '六级'):
            gsub('ielts', '雅思'):gsub('toefl', '托福'):gsub('gre', 'GRE')
        table.insert(text, '标签:')
        table.insert(text, '    ' .. tag)
        table.insert(text, '')
    end
end

-- NOTE: pos 词性
local function get_pos(text, query_res)
    if #query_res.pos > 0 then
        table.insert(text, '词性:')
        for v in vim.gsplit(query_res.pos, [[/]]) do
            table.insert(text, string.format('    %s', v .. '%'))
        end
        table.insert(text, '')
    end
end

-- NOTE: exchange
local function get_exchange(text, query_res)
    if #query_res.exchange > 0 then
        table.insert(text, '词形变化:')
        local exchange_map = {
            p = '过去式',
            d = '过去分词',
            i = '现在分词',
            r = '形容词比较级',
            t = '形容词最高级',
            s = '名词复数形式',
            O = '词干',
            ['3'] = '第三人称单数',
        }
        for v in vim.gsplit(query_res.exchange, [[/]]) do
            table.insert(text, string.format('    %s:  %s', exchange_map[v:sub(1, 1)], v:sub(3)))
            -- FIXME: 中文字符与字母位宽不一致, 暂时无法对齐
        end
        table.insert(text, '')
    end
end

-- NOTE: 中文翻译
local function get_zh(text, query_res)
    if #query_res.translation > 0 then
        table.insert(text, '中文翻译:')
        for v in vim.gsplit(query_res.translation, '\n') do
            table.insert(text, '    ' .. v)
        end
        table.insert(text, '')
    end
end


-- NOTE: 英文翻译
local function get_en(text, query_res)
    if #query_res.definition > 0 then
        table.insert(text, '英文翻译:')
        for v in vim.gsplit(query_res.definition, '\n') do
            table.insert(text, '    ' .. v)
        end
        table.insert(text, '')
    end
end


local handler = {
    title = get_title,
    tag = get_tag,
    pos = get_pos,
    exchange = get_exchange,
    zh = get_zh,
    en = get_en,
}


-- @return string array
local function get_text(query_res)
    local text = {}
    for _, v in ipairs(order) do
        handler[v](text, query_res)
    end
    return text
end



local function set_text(query_res)
    local text = query_res and get_text(query_res) or { '没有找到相关定义' }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
    local width = 0
    for _, v in ipairs(text) do
        if v:len() > width then
            width = v:len()
        end
    end
    return width, #text
end

function M.query_cursor()
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    local word = vim.fn.expand('<cword>')
    local res = require("Trans.database").query(word)
    local width, height = set_text(res)
    show_win(width, height)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

function M.query()
    -- TODO:
end

function M.toggle()
    -- TODO: wrap some function
end

function M.close_win()
    if win > 0 then
        vim.api.nvim_win_close(win, true)
        win = 0
    end
end

return M
