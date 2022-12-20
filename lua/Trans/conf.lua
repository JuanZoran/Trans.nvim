return {
    display = {
        style = 'minimal',
        max_height = 50,
        max_width = 50,
        -- phnoetic = true,
        collins_star = true,
        pos = true,
        tag = true,
        oxford = true,
        -- history = false,
        exchange = true,
        Trans_en = true,
        Trans_zh = true,
        wrap = true,
    },
    view = {
        -- TODO: style: buffer | cursor | window
        -- style = 'buffer',
        -- buffer_pos = 'bottom', -- only works when view.style == 'buffer'
    },
    db_path = '/home/zoran/project/neovim/ecdict-ultimate-sqlite/ultimate.db', -- FIXME: change the path

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

    -- TODO: leamma search
    -- leamma = false,

    -- TODO: register word
}
