return {
    display = {
        style = 'minimal',
        max_height = 50, -- 小于0代表无限制
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
    buf = vim.api.nvim_create_buf(false, true)

    -- TODO:  add online translate engine
    -- online_search = {
    --     enable = false,
    --     engine = {},
    -- }

    -- TODO: register word
}
