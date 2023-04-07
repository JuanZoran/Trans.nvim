local M = {}
local api, fn = vim.api, vim.fn

if fn.executable 'sqlite3' ~= 1 then
    error 'Please check out sqlite3'
end

local win_title = fn.has 'nvim-0.9' == 1 and {
    { '',       'TransTitleRound' },
    { ' Trans', 'TransTitle' },
    { '',       'TransTitleRound' },
} or nil

-- local title = {
--     "████████╗██████╗  █████╗ ███╗   ██╗███████╗",
--     "╚══██╔══╝██╔══██╗██╔══██╗████╗  ██║██╔════╝",
--     "   ██║   ██████╔╝███████║██╔██╗ ██║███████╗",
--     "   ██║   ██╔══██╗██╔══██║██║╚██╗██║╚════██║",
--     "   ██║   ██║  ██║██║  ██║██║ ╚████║███████║",
--     "   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝",
--}

string.width = api.nvim_strwidth
string.isEn = function(self)
    local char = { self:byte(1, -1) }
    for i = 1, #self do
        if char[i] > 128 then
            return false
        end
    end
    return true
end

string.play = fn.has 'linux' == 1 and function(self)
    local cmd = ([[echo "%s" | festival --tts]]):format(self)
    fn.jobstart(cmd)
end or fn.has 'mac' == 1 and function(self)
    local cmd = ([[say "%s"]]):format(self)
    fn.jobstart(cmd)
end or function(self)
    local seperator = fn.has 'unix' and '/' or '\\'
    local file = debug.getinfo(1, 'S').source:sub(2):match '(.*)lua' .. seperator .. 'tts' .. seperator .. 'say.js'
    fn.jobstart('node ' .. file .. ' ' .. self)
end

M.conf = {
    warning = true,
    view = {
        i = 'float',
        n = 'hover',
        v = 'hover',
    },
    hover = {
        width = 37,
        height = 27,
        border = 'rounded',
        title = win_title,
        keymap = {
            pageup = '[[',
            pagedown = ']]',
            pin = '<leader>[',
            close = '<leader>]',
            toggle_entry = '<leader>;',
            play = '_',
        },
        animation = {
            -- open = 'fold',
            -- close = 'fold',
            open = 'slid',
            close = 'slid',
            interval = 12,
        },
        auto_close_events = {
            'InsertEnter',
            'CursorMoved',
            'BufLeave',
        },
        auto_play = true,
        timeout = 2000,
        spinner = 'dots', -- 查看所有样式: /lua/Trans/util/spinner
        -- spinner = 'moon'
    },
    float = {
        width = 0.8,
        height = 0.8,
        border = 'rounded',
        title = win_title,
        keymap = {
            quit = 'q',
        },
        animation = {
            open = 'fold',
            close = 'fold',
            interval = 10,
        },
        tag = {
            wait = '#519aba',
            fail = '#e46876',
            success = '#10b981',
        },
    },
    order = { -- only work on hover mode
        'title',
        'tag',
        'pos',
        'exchange',
        'translation',
        'definition',
    },
    icon = {
        star = '',
        notfound = ' ',
        yes = '✔',
        no = '',
        -- --- char: ■ | □ | ▇ | ▏ ▎ ▍ ▌ ▋ ▊ ▉ █
        -- --- ◖■■■■■■■◗▫◻ ▆ ▆ ▇⃞ ▉⃞
        cell = '■',
        -- star = '⭐',
        -- notfound = '❔',
        -- yes = '✔️',
        -- no = '❌'
    },
    theme = 'default',
    -- theme = 'dracula',
    -- theme = 'tokyonight',

    db_path = '$HOME/.vim/dict/ultimate.db',
    engine = {
        youdao = {},
        -- baidu = {
        --     appid = '',
        --     appPasswd = '',
        -- },
        -- -- youdao = {
        --     appkey = '',
        --     appPasswd = '',
        -- },
    },
}

M.setup = function(opts)
    if opts then
        M.conf = vim.tbl_deep_extend('force', M.conf, opts)
    end
    local conf = M.conf

    local float = conf.float
    if 0 < float.height and float.height <= 1 then
        float.height = math.floor((vim.o.lines - vim.o.cmdheight - 1) * float.height)
    end
    if 0 < float.width and float.width <= 1 then
        float.width = math.floor(vim.o.columns * float.width)
    end

    local engines = {}
    local i = 1
    for k, _ in pairs(conf.engine) do
        engines[i] = k
        i = i + 1
    end
    conf.engines = engines

    local set_hl = api.nvim_set_hl
    local hls    = require 'Trans.ui.theme'[conf.theme]
    for hl, opt in pairs(hls) do
        set_hl(0, hl, opt)
    end


    if M.conf.warning then
        vim.notify([[
新版本v2已经发布, 见:
    https://github.com/JuanZoran/Trans.nvim
该分支已经不再维护, 请尝试迁移到新分支
        ]], vim.log.levels.WARN)
    end
end

local function get_select()
    local _start = fn.getpos 'v'
    local _end = fn.getpos '.'

    if _start[2] > _end[2] or (_start[3] > _end[3] and _start[2] == _end[2]) then
        _start, _end = _end, _start
    end
    local s_row, s_col = _start[2], _start[3]
    local e_row, e_col = _end[2], _end[3]

    -- print(s_row, e_row, s_col, e_col)
    ---@type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local line = fn.getline(e_row)
    local uidx = vim.str_utfindex(line, math.min(#line, e_col))
    e_col = vim.str_byteindex(line, uidx)

    if s_row == e_row then
        return line:sub(s_col, e_col)
    else
        local lines = fn.getline(s_row, e_row)
        local i = #lines
        lines[1] = lines[1]:sub(s_col)
        lines[i] = line:sub(1, e_col)
        return table.concat(lines)
    end
end

M.get_word = function(mode)
    local word
    if mode == 'n' then
        word = fn.expand '<cword>'
    elseif mode == 'v' then
        api.nvim_input '<ESC>'
        word = get_select()
    elseif mode == 'i' then
        -- TODO Use Telescope with fuzzy finder
        ---@diagnostic disable-next-line: param-type-mismatch
        word = fn.input '请输入需要查询的单词:'
    else
        error('invalid mode: ' .. mode)
    end
    return word
end


M.translate = function(mode, view)
    if M.conf.warning then
        vim.notify([[
新版本已经发布, 见:
    https://github.com/JuanZoran/Trans.nvim
该分支已经不再维护, 请尝试迁移到新分支
        ]], vim.log.levels.WARN)
    end

    vim.validate {
        mode = { mode, 's', true },
        view = { view, 's', true },
    }

    mode = mode or api.nvim_get_mode().mode
    view = view or M.conf.view[mode]
    assert(mode and view)
    local word = M.get_word(mode)
    if word == nil or word == '' then
        return
    else
        require('Trans.view.' .. view)(word:gsub('^%s+', '', 1))
    end
end

M.ns = api.nvim_create_namespace 'Trans'

return M
