local M = {}

local title = vim.fn.has('nvim-0.9') == 1 and {
    { '', 'TransTitleRound' },
    { ' Trans', 'TransTitle' },
    { '', 'TransTitleRound' },
} or nil


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
        timeout = 3000,
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
        engine = {
            '本地',
        }
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

    local float = M.conf.float

    if 0 < float.height and float.height <= 1 then
        float.height = math.floor((vim.o.lines - vim.o.cmdheight - 1) * float.height)
    end

    if 0 < float.width and float.width <= 1 then
        float.width = math.floor(vim.o.columns * float.width)
    end

    times = times + 1
    if times == 1 then
        M.translate = require('Trans.translate')

        if vim.fn.executable('sqlite3') ~= 1 then
            error('Please check out sqlite3')
        end

        vim.api.nvim_create_user_command('Translate', function ()
            M.translate()
        end, { desc = '  单词翻译', })

        vim.api.nvim_create_user_command('TranslateInput', function()
            M.translate('i')
        end, { desc = '  搜索翻译' })


        local hls = require('Trans.theme')[M.conf.theme]
        for hl, opt in pairs(hls) do
            vim.api.nvim_set_hl(0, hl, opt)
        end
    end
end

M.augroup = vim.api.nvim_create_augroup('Trans', { clear = true })

return M
