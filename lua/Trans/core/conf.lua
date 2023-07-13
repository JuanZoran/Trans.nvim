---@class Trans
---@field conf TransConf


---@alias TransMode 'visual' 'input'

---@class TransConf
return {
    ---@type string the directory for database file and password file
    dir      = require 'Trans'.plugin_dir,
    ---@type 'default' | 'dracula' | 'tokyonight' global Trans theme [@see lua/Trans/style/theme.lua]
    theme    = 'default', -- default | tokyonight | dracula
    ---@type table<TransMode, { frontend:string, backend:string | string[] }> fallback strategy for mode
    strategy = {
        default = {
            frontend = 'hover',
            backend = {
                'offline',
                -- 'youdao',
                -- 'baidu',
            }
        },
        -- input = {
        -- visual = {
        -- ...
    },
    ---@type table frontend options
    frontend = {
        ---@class TransFrontendOpts
        ---@field keymaps table<string, string>
        default = {
            auto_play = true,
            query     = 'fallback',
            border    = 'rounded',
            title     = vim.fn.has 'nvim-0.9' == 1 and {
                    { '',       'TransTitleRound' },
                    { ' Trans', 'TransTitle' },
                    { '',       'TransTitleRound' },
                } or nil, -- need nvim-0.9+
            ---@type {open: string | boolean, close: string | boolean, interval: integer} Hover Window Animation
            animation = {
                open = 'slid', -- 'fold', 'slid'
                close = 'slid',
                interval = 12,
            },
            timeout   = 2000,
        },
        ---@class TransHoverOpts : TransFrontendOpts
        hover = {
            ---@type integer Max Width of Hover Window
            width             = 37,
            ---@type integer Max Height of Hover Window
            height            = 27,
            ---@type string -- see: /lua/Trans/style/spinner
            spinner           = 'dots',
            ---@type string
            fallback_message  = '{{notfound}} {{error_message}}',
            auto_resize       = true,
            split_width       = 60,
            padding           = 10, -- padding for hover window width
            keymaps           = {
                -- pageup       = '<C-u>',
                -- pagedown     = '<C-d>',
                -- pin          = '<leader>[',
                -- close        = '<leader>]',
                -- toggle_entry = '<leader>;',
            },
            ---@type string[] auto close events
            auto_close_events = {
                'InsertEnter',
                'CursorMoved',
                'BufLeave',
            },
            ---@type table<string, string[]> order to display translate result
            order             = {
                default = {
                    'str',
                    'translation',
                    'definition',
                },
                offline = {
                    'title',
                    'tag',
                    'pos',
                    'exchange',
                    'translation',
                    'definition',
                },
                youdao = {
                    'title',
                    'translation',
                    'definition',
                    'web',
                },
            },
            icon              = {
                -- or use emoji
                list        = '●', -- ● | ○ | ◉ | ◯ | ◇ | ◆ | ▪ | ▫ | ⬤ | 🟢 | 🟡 | 🟣 | 🟤 | 🟠| 🟦 | 🟨 | 🟧 | 🟥 | 🟪 | 🟫 | 🟩 | 🟦
                star        = '', -- ⭐ | ✴ | ✳ | ✲ | ✱ | ✰ | ★ | ☆ | 🌟 | 🌠 | 🌙 | 🌛 | 🌜 | 🌟 | 🌠 | 🌌 | 🌙 |
                notfound    = ' ', --❔ | ❓ | ❗ | ❕|
                yes         = '✔', -- ✅ | ✔️ | ☑
                no          = '', -- ❌ | ❎ | ✖ | ✘ | ✗ |
                cell        = '■', -- ■  | □ | ▇ | ▏ ▎ ▍ ▌ ▋ ▊ ▉
                web         = '󰖟', --🌍 | 🌎 | 🌏 | 🌐 |
                tag         = '',
                pos         = '',
                exchange    = '',
                definition  = '󰗊',
                translation = '󰊿',
            },
        },
    },



   -- debug    = true,
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
