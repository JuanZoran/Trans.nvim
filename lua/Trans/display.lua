-- local conf = require("Trans").conf
local M = {}

local display = require("Trans.conf").display
local icon = require("Trans.conf").icon


local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_option(buf, 'filetype', 'Trans')


-- {
--     audio = "",
--     bnc = 5222,
--     definition = "n. slang for sexual intercourse",
--     exchange = "d:fucked/p:fucked/i:fucking/3:fucks/s:fucks",
--     frq = 5040,
--     id = 1180286,
--     phonetic = "fʌk",
--     pos = "n:37/v:63",
--     sw = "fuck",
--     tag = "",
--     translation = "vt. 与...性交, 欺骗, 诅咒\nvi. 性交\nn. 性交, 些微, 杂种\ninterj. 他妈的, 混帐",
--     word = "fuck"
--  }

local function show_win(width, height)
    vim.api.nvim_open_win(buf, true, {
        relative = 'cursor',
        title = 'Trans',
        title_pos = 'center',
        style = display.style,
        row = 0, col = 0, width = width > display.max_width and display.max_width or width,
        height = height > display.max_height and display.max_height or height,
        border = 'rounded',
        focusable = false,
    })
    -- vim.api.nvim_win_set_option(win, 'warp', true)

end

-- @return string array
local function get_text(query_res)
    local text = {
        -- NOTE: word + phonetic + collins_star
        string.format('%s    [%s]    ', query_res.word, query_res.phonetic) ..
            (display.oxford and (query_res.oxford == 1 and icon.isOxford .. '    ' or icon.notOxford .. '    ') or '') ..
            ((display.collins_star and query_res.collins) and string.rep(icon.star, query_res.collins) or '')
    }

    -- NOTE: tag
    if display.tag and query_res.tag:len() > 0 then
        local tag = query_res.tag:gsub('zk', '中考'):gsub('gk', '高考'):gsub('ky', '考研'):gsub('cet4', '四级'):
            gsub('cet6', '六级'):
            gsub('ielts', '雅思'):gsub('toefl', '托福'):gsub('gre', 'GRE')
        table.insert(text, '标签:')
        table.insert(text, '    ' .. tag)
    end
    table.insert(text, '')

    -- NOTE: pos 词性
    if display.pos and query_res.pos:len() > 0 then
        table.insert(text, '词性:')
        -- TODO: figure out pos sense
        table.insert(text, '    ' .. query_res.pos)
    end

    -- NOTE: exchange
    if display.exchange and query_res.exchange:len() > 0 then
        -- local list = vim.gsplit(query_res.exchange, [[\]])
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
    end
    table.insert(text, '')

    -- NOTE: 中文翻译
    if display.Trans_zh and query_res.translation:len() > 0 then

        table.insert(text, '中文翻译:')
        for v in vim.gsplit(query_res.translation, '\n') do
            -- table.insert(text, '    ' .. v)
            table.insert(text, '    ' .. v)
        end
    end
    table.insert(text, '')

    -- NOTE: 英文翻译
    if display.Trans_en and query_res.definition:len() > 0 then
        table.insert(text, '英文翻译:')
        for v in vim.gsplit(query_res.definition, '\n') do
            table.insert(text, '    ' .. v)
        end
    end
    table.insert(text, '')

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

    vim.pretty_print(res)

    local width, height = set_text(res)
    show_win(width, height)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

function M.query()
    -- TODO:
end

return M
