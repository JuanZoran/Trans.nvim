local M = {}

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
        title = {
            { '', 'TransTitleRound' },
            { ' Trans', 'TransTitle' },
            { '', 'TransTitleRound' },
        },
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
        }
    },
    order = {
        -- offline = {
        'title',
        'tag',
        'pos',
        'exchange',
        'translation',
        'definition',
        -- },
        -- online = {
        --     -- TODO
        -- },
    },
    icon = {
        star = '',
        -- notfound = '❔',
        notfound = ' ',
        yes = ' ',
        no = ''
        -- yes = '✔️',
        -- no = '❌'
        -- star = '⭐',
    },

    db_path = '$HOME/.vim/dict/ultimate.db',

    -- TODO :
    -- engine = {
    --     -- TODO
    --     'offline',
    -- }
    -- history = {
    --     -- TOOD
    -- }

    -- TODO  add online translate engine
    -- online_search = {
    --     enable = false,
    --     engine = {},
    -- }

    -- TODO register word
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
    require("Trans.setup")
end

M.augroup = vim.api.nvim_create_augroup('Trans', { clear = true })

return M
