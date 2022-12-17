return {
    display = {
        style = 'default',
        phnoetic = true,
        collins_star = true,
        tag = true,
        oxford = true,
        history = false,
    },
    default_keymap = true,
    map = {

    },

    view = {
        -- TODO: style: buffer | cursor | window
        -- style = 'buffer',
        -- buffer_pos = 'bottom', -- only works when view.style == 'buffer'
    },

    db_path = '/home/zoran/project/neovim/ecdict-sqlite-28/stardict.db', -- FIXME: change the path

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
