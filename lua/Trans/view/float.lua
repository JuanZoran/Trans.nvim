-- local function generate_opts(view)
--     -- TODO :
--     vim.validate {
--         view = { view, 's' },
--     }
--     local hover     = conf.hover
--     local float     = conf.float
--     local title_pos = 'center'
--     local title     = {
--         { '', 'TransTitleRound' },
--         -- { '', 'TransTitleRound' },
--         { conf.icon.title .. ' Trans', 'TransTitle' },
--         -- { '', 'TransTitleRound' },
--         { '', 'TransTitleRound' },
--     }
--
--     return ({
--         hover = {
--             relative  = 'cursor',
--             width     = hover.width,
--             height    = hover.height,
--             border    = hover.border,
--             title     = title,
--             title_pos = title_pos,
--             focusable = false,
--             zindex    = 100,
--             col       = 2,
--             row       = 2,
--         },
--         float = {
--             relative  = 'editor',
--             width     = float.width,
--             height    = float.height,
--             border    = float.border,
--             title     = title,
--             title_pos = title_pos,
--             focusable = false,
--             zindex    = 75,
--             row       = math.floor((vim.o.lines - float.height) / 2),
--             col       = math.floor((vim.o.columns - float.width) / 2),
--         },
--     })[view]
-- end