local M   = {}
local api = vim.api
local fn  = vim.fn

local title = fn.has('nvim-0.9') == 1 and {
    { '', 'TransTitleRound' },
    { ' Trans', 'TransTitle' },
    { '', 'TransTitleRound' },
} or nil


string.width = api.nvim_strwidth
string.isEn = function(self)
    local char = { self:byte(1, -1) }
    for i = 1, #self do
        if char[i] > 127 then
            return false
        end
    end
    return true
end


string.play = fn.has('linux') == 1 and function(self)
    local cmd = ([[echo "%s" | festival --tts]]):format(self)
    fn.jobstart(cmd)
end or function(self)
    local seperator = fn.has('unix') and '/' or '\\'
    local file = debug.getinfo(1, "S").source:sub(2):match('(.*)lua') .. seperator .. 'tts' .. seperator .. 'say.js'
    fn.jobstart('node ' .. file .. ' ' .. self)
end


M.conf = {
    view = {
        i = 'float',
        n = 'hover',
        v = 'hover',
    },
    hover = {
        width = 37,
        height = 27,
        border = 'rounded',
        title = title,
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
        title = title,
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
        -- baidu = {
        --     appid = '',
        --     appPasswd = '',
        -- },
        -- -- youdao = {
        --     appkey = '',
        --     appPasswd = '',
        -- },
    },

    -- TODO :
    -- register word
    -- history = {
    --     -- TOOD
    -- }

    -- TODO :add online translate engine
}

local times = 0
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
    for k, _ in pairs(conf.engine) do
        table.insert(engines, k)
    end
    conf.engines = engines

    times = times + 1
    if times == 1 then

        local get_mode    = api.nvim_get_mode
        local set_hl      = api.nvim_set_hl
        local new_command = api.nvim_create_user_command

        if fn.executable('sqlite3') ~= 1 then
            error('Please check out sqlite3')
        end

        new_command('Translate', function()
            M.translate()
        end, { desc = '  单词翻译', })

        new_command('TranslateInput', function()
            M.translate('i')
        end, { desc = '  搜索翻译' })

        new_command('TransPlay', function()
            local word = M.get_word(get_mode().mode)
            if word ~= '' and word:isEn() then
                word:play()
            end
        end, { desc = ' 自动发音' })

        local hls = require('Trans.ui.theme')[conf.theme]
        for hl, opt in pairs(hls) do
            set_hl(0, hl, opt)
        end
    end
end

local function get_select()
    local _start = fn.getpos("v")
    local _end = fn.getpos('.')

    if _start[2] > _end[2] or (_start[3] > _end[3] and _start[2] == _end[2]) then
        _start, _end = _end, _start
    end
    local s_row = _start[2]
    local e_row = _end[2]
    local s_col = _start[3]
    local e_col = _end[3]

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
        word = fn.expand('<cword>')

    elseif mode == 'v' then
        api.nvim_input('<ESC>')
        word = get_select()

    elseif mode == 'i' then
        -- TODO Use Telescope with fuzzy finder
        vim.ui.input({ prompt = '请输入需要查询的单词: ' }, function(input)
            word = input
        end)
    else
        error('invalid mode: ' .. mode)
    end
    return word
end


M.translate = function(mode, view)
    vim.validate {
        mode = { mode, 's', true },
        view = { view, 's', true }
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

M.ns = api.nvim_create_namespace('Trans')

return M
