return {
    display = {
        style = 'minimal',
        max_height = 50,
        max_width = 50,
        -- phnoetic = true,
        collins_star = true,
        oxford = true,
        -- history = false,
        wrap = true,
        border_style = 'rounded',
        view = 'cursor',
        offset_x = 2,
        offset_y = 2,
    },
    order = {
        'title',
        'tag',
        'pos',
        'exchange',
        'zh',
        'en',
    },

    db_path = '$HOME/.vim/dict/ultimate.db', -- FIXME: change the path

    icon = {
        star = '⭐',
        isOxford = '✔',
        notOxford = ''
    },
    auto_close = true,
    -- TODO: async process
    -- async = false,

    -- TODO:  add online translate engine
    -- online_search = {
    --     enable = false,
    --     engine = {},
    -- }

    -- TODO: precise match or return closest match result
    -- precise_match = true,

    -- TODO: lemma search
    -- lemma = false,

    -- TODO: register word
}
