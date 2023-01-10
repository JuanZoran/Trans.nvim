local M = {}

M.conf = {
    style = {
        ui = {
            input = 'float',
            n = 'cursor',
            v = 'cursor',
        },
        window = {
            cursor = {
                border = 'rounded',
                width = 40,
                height = 50,
            },
            float = {
                border = 'rounded',
                width = 0.9,
                height = 0.8,
            },
        },
    },

    order = {
        offline = {
            'Title',
            'Tag',
            'Pos',
            'Exchange',
            'Translation',
            -- NOTE :如果你想限制某个组件的行数，可以设置max_size
            -- { 'Definition', max_size = 4 },
        },
        -- online = {
        --     -- TODO
        -- },
    },
    ui = {
        highlight = {
            TransWord = {
                fg = '#7ee787',
                bold = true,
            },
            TransPhonetic = {
                link = 'Linenr'
            },
            TransRef = {
                fg = '#75beff',
                bold = true,
            },
            TransTag = {
                fg = '#e5c07b',
            },
            TransExchange = {
                link = 'TransTag',
            },
            TransPos = {
                link = 'TransTag',
            },
            TransTranslation = {
                link = 'TransWord',
            },
            TransDefinition = {
                -- fg = '#bc8cff',
                link = 'Moremsg',
            },
            TransCursorWin = {
                link = 'Normal',
            },

            TransCursorBorder = {
                link = 'FloatBorder',
            }
        },
        icon = {
            star = '⭐',
            isOxford = '✔',
            notOxford = ''
        },
        display = {
            phnoetic = true,
            collins = true,
            oxford = true,
            -- TODO
            -- history = false,
        },
    },
    base = {
        db_path = '$HOME/.vim/dict/ultimate.db',
        auto_close = true,
        engine = {
            -- TODO
            'offline',
        }
    },
    -- map = {
    --     -- TODO
    -- },
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

-- INFO :加载的规则 [LuaRule]
M.replace_rules = {
    'order.*',
    'ui.highlight.*',
}


return M
