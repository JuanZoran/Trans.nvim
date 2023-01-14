local M = {}

M.conf = {
    view = {
        input = 'float',
        n = 'hover',
        v = 'hover',
    },
    window = {
        border = 'rounded',
        hover = {
            width = 36,
            height = 26,
        },
        float = {
            width = 0.8,
            height = 0.8,
        },
    },

    order = {
        -- offline = {
        'title',
        'tag',
        'pos',
        'exchange',
        'translation',
        -- NOTE :如果你想限制某个组件的行数，可以设置max_size
        -- { 'Definition', max_size = 4 },
        'definition',
        -- },
        -- online = {
        --     -- TODO
        -- },
    },
    icon = {
        title = ' ',
        star = '',
        -- notfound = '',
        -- yes = '',
        -- no = ''
        -- star = '⭐',
        notfound = '❔',
        yes = '✔️',
        no = '❌'
    },
    db_path = '$HOME/.vim/dict/ultimate.db',
    -- TODO :
    -- engine = {
    --     -- TODO
    --     'offline',
    -- }
    keymap = {
        -- TODO
        hover = {
            pageup = '[[',
            pagedown = ']]',
        },
    },
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
    local window = M.conf.window
    assert(window.hover.width > 1 and window.hover.height > 1)
    assert(0 < window.float.width and window.float.width <= 1)
    assert(0 < window.float.height and window.float.height <= 1)

    window.float.height = math.floor((vim.o.lines - vim.o.cmdheight - 1) * window.float.height)
    window.float.width = math.floor(vim.o.columns * window.float.width)


    M.translate = require('Trans.core').translate
    require("Trans.setup")
end


M.augroup = vim.api.nvim_create_augroup('Trans', { clear = true })

return M
