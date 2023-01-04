local M = {}

local api        = vim.api
local display    = require("Trans").conf.display
local icon       = require("Trans").conf.icon
local order      = require("Trans").conf.order
local auto_close = require("Trans").conf.auto_close

local hl = require("Trans.highlight").hlgroup

local buf = require("Trans.conf").buf
local win = 0
local line = 0
local pos_info = {}

local handler = {}
api.nvim_buf_set_option(buf, 'filetype', 'Trans')

local function show_win(width, height)
    win = api.nvim_open_win(buf, false, {
        relative = 'cursor',
        col = display.offset_x,
        row = display.offset_y,
        title = 'Trans',
        title_pos = 'center',
        style = display.style,
        width = (display.max_width > 0 and width > display.max_width) and display.max_width or width,
        height = (display.max_width > 0 and height > display.max_height) and display.max_height or height,
        border = display.border_style,
        focusable = false,
        zindex = 250, -- Top
    })
    api.nvim_win_set_option(win, 'wrap', display.wrap)
end

-- NOTE title
handler.title = function(text, query_res)
    local title = ('%s    [%s]    %s    %s'):format(
        query_res.word,
        query_res.phonetic,
        (display.oxford and (query_res.oxford == 1 and icon.isOxford or icon.notOxford) or ''),
        ((display.collins_star and query_res.collins) and string.rep(icon.star, query_res.collins) or '')
    )
    table.insert(text, title)

    pos_info.title = {}
    pos_info.title.word = #query_res.word
    pos_info.title.phonetic = query_res.phonetic and #query_res.phonetic or 3
    pos_info.title.line = line
    line = line + 1
end

-- NOTE  tag
handler.tag = function(text, query_res)
    if query_res.tag and #query_res.tag > 0 then
        local tag = query_res.tag:gsub('zk', '中考'):gsub('gk', '高考'):gsub('ky', '考研'):gsub('cet4', '四级'):
            gsub('cet6', '六级'):gsub('ielts', '雅思'):gsub('toefl', '托福'):gsub('gre', 'GRE')

        table.insert(text, '标签:')
        table.insert(text, '    ' .. tag)
        table.insert(text, '')

        pos_info.tag = line
        line = line + 3
    end
end

-- NOTE pos 词性
handler.pos = function(text, query_res)
    if query_res.pos and #query_res.pos > 0 then
        table.insert(text, '词性:')

        local content = 0
        for v in vim.gsplit(query_res.pos, [[/]]) do
            table.insert(text, string.format('    %s', v .. '%'))
            content = content + 1
        end

        table.insert(text, '')

        pos_info.pos = {}
        pos_info.pos.line = line
        pos_info.pos.content = content
        line = line + content + 2
    end
end

-- NOTE exchange
handler.exchange = function(text, query_res)
    if query_res.exchange and #query_res.exchange > 0 then
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

        local content = 0
        for v in vim.gsplit(query_res.exchange, [[/]]) do
            table.insert(text, string.format('    %s:  %s', exchange_map[v:sub(1, 1)], v:sub(3)))
            content = content + 1
            -- FIXME: 中文字符与字母位宽不一致, 暂时无法对齐
        end
        table.insert(text, '')

        pos_info.exchange = {}
        pos_info.exchange.line = line
        pos_info.exchange.content = content
        line = line + content + 2
    end
end

-- NOTE  中文翻译
handler.zh = function(text, query_res)
    if query_res.translation then
        table.insert(text, '中文翻译:')

        local content = 0
        for v in vim.gsplit(query_res.translation, '\n') do
            table.insert(text, '    ' .. v)
            content = content + 1
        end
        table.insert(text, '')

        pos_info.zh = {}
        pos_info.zh.line = line
        pos_info.zh.content = content
        line = content + line + 2
    end
end

-- NOTE  英文翻译
handler.en = function(text, query_res)
    if query_res.definition and #query_res.definition > 0 then
        table.insert(text, '英文翻译:')

        local content = 0
        for v in vim.gsplit(query_res.definition, '\n') do
            table.insert(text, '    ' .. v)
            content = content + 1
        end
        table.insert(text, '')

        pos_info.en = {}
        pos_info.en.line = line
        pos_info.en.content = content
        line = line + content + 2
    end
end

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

    api.nvim_buf_set_lines(buf, 0, -1, false, text)
    local width = 0
    for _, v in ipairs(text) do
        if #v > width then
            width = v:len()
        end
    end
    return width, #text
end

local hl_handler = {}

hl_handler.title = function()
    api.nvim_buf_add_highlight(buf, -1, hl.word, pos_info.title.line, 0, pos_info.title.word)
    api.nvim_buf_add_highlight(buf, -1, hl.phonetic, pos_info.title.line, pos_info.title.word + 5,
        pos_info.title.word + 5 + pos_info.title.phonetic)
end

hl_handler.tag = function()
    if pos_info.tag then
        api.nvim_buf_add_highlight(buf, -1, hl.ref, pos_info.tag, 0, -1)
        api.nvim_buf_add_highlight(buf, -1, hl.tag, pos_info.tag + 1, 0, -1)
    end
end

hl_handler.pos = function()
    if pos_info.pos then
        api.nvim_buf_add_highlight(buf, -1, hl.ref, pos_info.pos.line, 0, -1)
        for i = 1, pos_info.pos.content, 1 do
            api.nvim_buf_add_highlight(buf, -1, hl.pos, pos_info.pos.line + i, 0, -1)
        end
    end
end

hl_handler.exchange = function()
    if pos_info.exchange then
        api.nvim_buf_add_highlight(buf, -1, hl.ref, pos_info.exchange.line, 0, -1)
        for i = 1, pos_info.exchange.content, 1 do
            api.nvim_buf_add_highlight(buf, -1, hl.exchange, pos_info.exchange.line + i, 0, -1)
        end
    end
end

hl_handler.zh = function()
    api.nvim_buf_add_highlight(buf, -1, hl.ref, pos_info.zh.line, 0, -1)
    for i = 1, pos_info.zh.content, 1 do
        api.nvim_buf_add_highlight(buf, -1, hl.zh, pos_info.zh.line + i, 0, -1)
    end
end

hl_handler.en = function()
    if pos_info.en then
        api.nvim_buf_add_highlight(buf, -1, hl.ref, pos_info.en.line, 0, -1)
        for i = 1, pos_info.en.content, 1 do
            api.nvim_buf_add_highlight(buf, -1, hl.en, pos_info.en.line + i, 0, -1)
        end
    end
end


local function set_hl()
    for _, v in ipairs(order) do
        hl_handler[v]()
    end
end

local function clear_tmp_info()
    pos_info = {}
    line = 0
end

local function get_visual_selection()
    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    assert(s_end[2] == s_start[2])
    local lin = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)[1]
    local word = string.sub(lin, s_start[3], s_end[3])
    return word
end

function M.query(mode)
    assert(buf > 0)
    local word = ''
    if mode == 'n' then
        word = vim.fn.expand('<cword>')
    elseif mode == 'v' then
        word = get_visual_selection()
    elseif mode == 'I' then
        word = vim.fn.input('请输入您要查询的单词: ')
        -- vim.ui.input({prompt = '请输入您要查询的单词: '}, function (input)
        --     word = input
        -- end)
    else
        error('mode argument is invalid')
    end

    local res = require("Trans.database").query(word)
    local width, height = set_text(res)
    show_win(width, height)
    if res then
        set_hl()
        clear_tmp_info()
    end

    if auto_close then
        api.nvim_create_autocmd(
            { 'InsertEnter', 'CursorMoved', 'BufLeave', }, {
            buffer = 0,
            once = true,
            callback = M.close_win,
        })
    end
end

function M.query_cursor()
    M.query('n')
end

function M.query_select()
    M.query('v')
end

function M.query_input()
    M.query('I')
end

function M.close_win()
    if win > 0 then
        api.nvim_win_close(win, true)
        win = 0
    end
end

-- function M.enter_win()
--     if api.nvim_win_is_valid(win) then
--     else
--         error('current win is not valid')
--     end
-- end

return M
