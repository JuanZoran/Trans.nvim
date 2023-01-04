return {
    view = {
        cursor = {
            -- NOTE ：
            -- 可选的风格：['fixed', 'relative', .. ]
            style = 'fixed',
            border = 'rounded',
            -- NOTE :
            -- 如果style设置为'relative'
            -- 则其值代表最大限制, 设置为负数则无限制
            width = 30,
            height = 30,
        },
        float = {
            top_offset = 1,
            relative_width = 0.8,
            border = 'rounded',
        },
    },
    display = {
        phnoetic = true,
        collins_star = true,
        oxford = true,
        -- TODO
        -- history = false,
    },
    order = {
        'title',
        'tag',
        'pos',
        'exchange',
        'zh',
        'en',
    },

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
    db_path = '$HOME/.vim/dict/ultimate.db',

    icon = {
        star = '⭐',
        isOxford = '✔',
        notOxford = ''
    },
    auto_close = true,

    -- TODO  add online translate engine
    -- online_search = {
    --     enable = false,
    --     engine = {},
    -- }

    -- TODO register word
}
