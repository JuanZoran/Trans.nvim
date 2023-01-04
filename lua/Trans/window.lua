-- TODO  different style to display
local M = {}

M.float_opts = function(conf)
    local columns = vim.o.columns
    local height = vim.o.lines - vim.o.cmdheight - conf.top_offset
    local width = math.floor(columns * conf.relative_width)

    return {
        relative = 'editor',
        col = math.floor((columns - width) / 2), -- 两侧的宽度
        row = conf.top_offset,
        title = 'Trans',
        title_pos = 'center',
        style = 'minimal',
        width = width,
        height = height,
        border = conf.border,
        zindex = 50,
    }
end

M.cursor_opts = function (conf)
    local opts = {
        relative = 'cursor',
        col = 2,
        row = 2,
        title = 'Trans',
        title_pos = 'center',
        style = 'minimal',
        border = conf.border,
        -- TODO keymap to convert style to Float
        focusable = false,
        zindex = 100,
    }
    if conf.style == 'fixed' then
        opts.width = conf.width
        opts.height = conf.height
    elseif conf.style == 'relative' then
        opts.width = (conf.width > 0 and conf.width < conf.max_width) and conf.width  or conf.max_width
        opts.height = (conf.height > 0 and conf.height < conf.max_height) and conf.height  or conf.max_height
    else
        error('unknown style!')
    end
    return opts
end

return M
