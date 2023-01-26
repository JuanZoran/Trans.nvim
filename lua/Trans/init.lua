local M = {}


local title = vim.fn.has('nvim-0.9') and{
            { '', 'TransTitleRound' },
            { ' Trans', 'TransTitle' },
            { '', 'TransTitleRound' },
        }  or ' Trans'

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
            -- TODO :
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
    },
    float = {
        width = 0.8,
        height = 0.8,
        border = 'rounded',
        title = {
            { '', 'TransTitleRound' },
            { ' Trans', 'TransTitle' },
            { '', 'TransTitleRound' },
        },
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
        yes = ' ',
        no = ''
        -- star = '⭐',
        -- notfound = '❔',
        -- yes = '✔️',
        -- no = '❌'
    },
    theme = 'default',
    -- theme = 'dracula',
    -- theme = 'tokyonight',

    db_path = '$HOME/.vim/dict/ultimate.db',

    -- TODO :
    -- register word
    -- history = {
    --     -- TOOD
    -- }

    -- TODO :add online translate engine
}

M.setup = function(opts)
    if opts then
        M.conf = vim.tbl_deep_extend('force', M.conf, opts)
    end
    local hover = M.conf.hover
    local float = M.conf.float

    assert(hover.width > 1 and hover.height > 1)
    assert(0 < float.width and float.width <= 1)
    assert(0 < float.height and float.height <= 1)

    float.height = math.floor((vim.o.lines - vim.o.cmdheight - 1) * float.height)
    float.width = math.floor(vim.o.columns * float.width)

    M.translate = require('Trans.translate')

    if vim.fn.executable('sqlite3') ~= 1 then
        error('Please check out sqlite3')
    end

    vim.api.nvim_create_user_command('Translate', function()
        require("Trans").translate()
    end, { desc = '  单词翻译', })

    vim.api.nvim_create_user_command('TranslateInput', function()
        require("Trans").translate('i')
    end, { desc = '  搜索翻译' })


    local hls = require('Trans.theme')[M.conf.theme]
    for hl, opt in pairs(hls) do
        vim.api.nvim_set_hl(0, hl, opt)
    end
end

M.augroup = vim.api.nvim_create_augroup('Trans', { clear = true })

return M
