local title
if vim.fn.has('nvim-0.9') == 1 then
    title = {
        { '',       'TransTitleRound' },
        { ' Trans', 'TransTitle' },
        { '',       'TransTitleRound' },
    }
end

return {
    theme     = 'default', -- see lua/Trans/style/theme.lua
    auto_play = true,
    dir       = vim.fn.expand('$HOME/.vim/dict'),
    strategy  = {
        frontend = 'hover',
        backend = '*',
    },
    backend   = {
        timeout = 2000,
    },
    frontend  = {
        hover = {
            title = title, -- need nvim-0.9
            width = 37,
            height = 27,
            border = 'rounded',
            keymap = {
                pageup = '[[',
                pagedown = ']]',
                pin = '<leader>[',
                close = '<leader>]',
                toggle_entry = '<leader>;',
                play = '_',
            },
            animation = {
                open = 'slid', -- 'fold', 'slid'
                close = 'slid',
                interval = 12,
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
    -- or use emoji
    icon      = {
        star     = '', -- ⭐
        notfound = ' ', -- ❔
        yes      = '✔', -- ✔️
        no       = '', -- ❌
        cell     = '■', -- ■ | □ | ▇ | ▏ ▎ ▍ ▌ ▋ ▊ ▉ █
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
