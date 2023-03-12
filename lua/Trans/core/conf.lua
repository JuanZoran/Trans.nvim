local title
if vim.fn.has('nvim-0.9') == 1 then
    title = {
        { '',       'TransTitleRound' },
        { ' Trans', 'TransTitle' },
        { '',       'TransTitleRound' },
    }
end

return {
    dir      = '$HOME/.vim/dict',
    strategy = {
        frontend = 'hover',
        backend = '*',
    },
    backend  = {
        timeout = 2000,
    },
    frontend = {
        auto_play = true,
        border = 'rounded',
        animation = {
            open = 'slid', -- 'fold', 'slid'
            close = 'slid',
            interval = 12,
        },
        title = title,     -- need nvim-0.9
        hover = {
            width = 37,
            height = 27,
            keymap = {
                play         = '_',
                pageup       = '[[',
                pagedown     = ']]',
                pin          = '<leader>[',
                close        = '<leader>]',
                toggle_entry = '<leader>;',
            },
            auto_close_events = {
                'InsertEnter',
                'CursorMoved',
                'BufLeave',
            },
            order = {
                'title',
                'tag',
                'pos',
                'exchange',
                'translation',
                'definition',
            },
            spinner = 'dots', -- see: /lua/Trans/style/spinner
        },
    },
    style    = {
        -- see lua/Trans/style/theme.lua
        theme = 'default', -- default | tokyonight | dracula
        -- or use emoji
        icon  = {
            star     = '', -- ⭐
            notfound = ' ', -- ❔
            yes      = '✔', -- ✔️
            no       = '', -- ❌
            cell     = '■', -- ■ | □ | ▇ | ▏ ▎ ▍ ▌ ▋ ▊ ▉ █
        },
    },
}


-- TODO :
-- float = {
--     width = 0.8,
--     height = 0.8,
--     border = 'rounded',
--     keymap = {
--         quit = 'q',
--     },
--     animation = {
--         open = 'fold',
--         close = 'fold',
--         interval = 10,
--     },
--     tag = {
--         wait = '#519aba',
--         fail = '#e46876',
--         success = '#10b981',
--     },
-- },

-- local title = {
--     "████████╗██████╗  █████╗ ███╗   ██╗███████╗",
--     "╚══██╔══╝██╔══██╗██╔══██╗████╗  ██║██╔════╝",
--     "   ██║   ██████╔╝███████║██╔██╗ ██║███████╗",
--     "   ██║   ██╔══██╗██╔══██║██║╚██╗██║╚════██║",
--     "   ██║   ██║  ██║██║  ██║██║ ╚████║███████║",
--     "   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝",
--}
