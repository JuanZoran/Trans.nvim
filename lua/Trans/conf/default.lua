local M = {}

M.conf = {
    style = {
        ui = {
            input = 'float',
            cursor = 'cursor',
            select = 'cursor'
        },
        order = {
            'Title',
            'Tag',
            'Pos',
            'Exchange',
            'Translation',
            'Definition',
        },
        window = {
            cursor = {
                border = 'rounded',
                width = 30,
                height = 30,
            },
            float = {
                border = 'rounded',
                width = 0.8,
                height = 0.9,
            },
            -- NOTE :如果你想限制某个组件的行数，可以设置 (名称与order相同)
            -- Example:
            -- limit = {
            --     En = 1, -- 只显示第一行，（一般为最广泛的释义）
            -- },
            limit = nil,
        },
    },
    ui = {
        highligh = {
            TransWord = {
                fg = '#7ee787',
                bold = true,
            },
            TransPhonetic = {
                fg = '#8b949e',
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
            TransZh = {
                link = 'TransWord',
            },
            TransEn = {
                fg = '#bc8cff',
            },
        },
        icon = {
            star = '⭐',
            isOxford = '✔',
            notOxford = ''
        },
        display = {
            phnoetic = true,
            collins_star = true,
            oxford = true,
            -- TODO
            -- history = false,
        },
    },
    base = {
        db_path = '$HOME/.vim/dict/ultimate.db',
        auto_close = true,
        lazy_load = false,
        debug = {
            enable = true,
            type_check = true,
            unknown_conf = true,
        },
    },
    map = {
        -- TODO
    },
    -- TODO  add online translate engine
    -- online_search = {
    --     enable = false,
    --     engine = {},
    -- }

    -- TODO register word
}

-- INFO :加载的规则 [LuaRule]
M.replace_rules = {
    'order',
    'Trans.+',
}

return M
