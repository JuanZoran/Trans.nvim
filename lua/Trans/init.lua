local M = {}

local title = vim.fn.has('nvim-0.9') == 1 and {
    { '', 'TransTitleRound' },
    { ' Trans', 'TransTitle' },
    { '', 'TransTitleRound' },
} or nil


string.width = vim.fn.strwidth
string.isEn = function(self)
    local char = { self:byte(1, -1) }
    for i = 1, #self do
        if char[i] > 127 then
            return false
        end
    end
    return true
end


string.play = vim.fn.has('linux') == 1 and function(self)
    local cmd = ([[echo "%s" | festival --tts]]):format(self)
    vim.fn.jobstart(cmd)
end or function(self)
    local seperator = vim.fn.has('unix') and '/' or '\\'
    local file = debug.getinfo(1, "S").source:sub(2):match('(.*)lua') .. seperator .. 'tts' .. seperator .. 'say.js'
    vim.fn.jobstart('node ' .. file .. ' ' .. self)
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
        local api = vim.api

        local get_mode    = api.nvim_get_mode
        local set_hl      = api.nvim_set_hl
        local new_command = api.nvim_create_user_command

        if vim.fn.executable('sqlite3') ~= 1 then
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
    local s_start = vim.fn.getpos("v")
    local s_end = vim.fn.getpos(".")
    if s_start[2] > s_end[2] or s_start[3] > s_end[3] then
        s_start, s_end = s_end, s_start
    end

    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return table.concat(lines, '')
end

M.get_word = function(mode)
    local word
    if mode == 'n' then
        word = vim.fn.expand('<cword>')
    elseif mode == 'v' then
        vim.api.nvim_input('<ESC>')
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

    mode = mode or vim.api.nvim_get_mode().mode
    view = view or M.conf.view[mode]
    assert(mode and view)
    local word = M.get_word(mode)
    if word == nil or word == '' then
        return
    else
        require('Trans.view.' .. view)(word:gsub('^%s+', '', 1))
    end
end


M.augroup = vim.api.nvim_create_augroup('Trans', { clear = true })

return M
