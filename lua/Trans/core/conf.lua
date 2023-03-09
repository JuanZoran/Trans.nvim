return {
    view = {
        i = 'float',
        n = 'hover',
        v = 'hover',
    },
    hover = {
        width = 37,
        height = 27,
        border = 'rounded',
        title = vim.fn.has('nvim-0.9') == 1 and {
                { '',       'TransTitleRound' },
                { ' Trans', 'TransTitle' },
                { '',       'TransTitleRound' },
            } or nil,
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
    db_path = '$HOME/.vim/dict/ultimate.db',
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
}


-- ---Pasue Handler for {ms} milliseconds
-- ---@param ms number @milliseconds
-- M.pause = function(ms)
--     local co = coroutine.running()
--     vim.defer_fn(function()
--         coroutine.resume(co)
--     end, ms)
--     coroutine.yield()
-- end


-- local title = {
--     "████████╗██████╗  █████╗ ███╗   ██╗███████╗",
--     "╚══██╔══╝██╔══██╗██╔══██╗████╗  ██║██╔════╝",
--     "   ██║   ██████╔╝███████║██╔██╗ ██║███████╗",
--     "   ██║   ██╔══██╗██╔══██║██║╚██╗██║╚════██║",
--     "   ██║   ██║  ██║██║  ██║██║ ╚████║███████║",
--     "   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝",
--}

-- string.width = api.nvim_strwidth
