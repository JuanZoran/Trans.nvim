local title
if vim.fn.has('nvim-0.9') == 1 then
    title = {
        { '',       'TransTitleRound' },
        { ' Trans', 'TransTitle' },
        { '',       'TransTitleRound' },
    }
end


---@class Trans
---@field conf TransConf


---@class TransConf
return {
    ---@type string the directory for database file and password file
    dir      = os.getenv('HOME') .. '/.vim/dict',
    ---@type table modeStrategy default strategy for mode
    strategy = {
        ---@type { frontend:string, backend:string } fallback strategy for mode
        default = {
            frontend = 'hover',
            backend = '*',
        },
    },
    ---@type table<string, TransBackendOpts> fallback backend for mode
    backend  = {
        ---@class TransBackendOpts
        default = {
            ---@type integer timeout for backend send request
            timeout = 2000,
        },
    },
    ---@type table frontend options
    frontend = {
        ---@class TransFrontendOpts
        ---@field keymaps table<string, string>
        default = {
            ---@type boolean Whether to auto play the audio
            auto_play = true,
            border = 'rounded',
            title = title, -- need nvim-0.9
            ---@type {open: string | boolean, close: string | boolean, interval: integer} Hover Window Animation
            animation = {
                open = 'slid', -- 'fold', 'slid'
                close = 'slid',
                interval = 12,
            },
        },
        ---@class TransHoverOpts : TransFrontendOpts
        hover = {
            ---@type integer Max Width of Hover Window
            width             = 37,
            ---@type integer Max Height of Hover Window
            height            = 27,
            ---@type string -- see: /lua/Trans/style/spinner
            spinner           = 'dots',
            ---@type string -- TODO :support replace with {{special word}}
            fallback_message  = '翻译超时或没有找到相关的翻译',
            keymaps           = {
                play         = '_',
                pageup       = '[[',
                pagedown     = ']]',
                pin          = '<leader>[',
                close        = '<leader>]',
                toggle_entry = '<leader>;',
            },
            ---@type string[] auto close events
            auto_close_events = {
                'InsertEnter',
                'CursorMoved',
                'BufLeave',
            },
            ---@type string[] order to display translate result
            order             = {
                'title',
                'tag',
                'pos',
                'exchange',
                'translation',
                'definition',
            },
            ---@type table<string, string>
            icon              = {
                -- or use emoji
                star     = '', -- ⭐
                notfound = ' ', -- ❔
                yes      = '✔', -- ✔️
                no       = '', -- ❌
                cell     = '■', -- ■ | □ | ▇ | ▏ ▎ ▍ ▌ ▋ ▊ ▉ █
            },
        },
    },
    style    = {
        ---@type string global Trans theme [see lua/Trans/style/theme.lua]
        theme = 'default', -- default | tokyonight | dracula
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