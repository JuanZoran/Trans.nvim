local M = {}
local conf = require("Trans.conf.loader").loaded_conf.style.window
local type_check = require("Trans.util.debug").type_check

-- FIXME 

local get_float_opts = function(float_conf)
    type_check {
        float_conf = { float_conf, 'table' },
    }
    local columns = vim.o.columns
    local height = vim.o.lines - vim.o.cmdheight - float_conf.top_offset
    local width = math.floor(columns * float_conf.relative_width)

    return {
        relative = 'editor',
        col = math.floor((columns - width) / 2), -- 两侧的宽度
        row = float_conf.top_offset,
        title = 'Trans',
        title_pos = 'center',
        style = 'minimal',
        width = width,
        height = height,
        border = float_conf.border,
        zindex = 50,
    }
end

local get_cursor_opts = function(cursor_conf)
    type_check {
        cursor_conf = { cursor_conf, 'table' },
    }
    local opts = {
        relative = 'cursor',
        col = 2,
        row = 2,
        title = 'Trans',
        title_pos = 'center',
        style = 'minimal',
        border = cursor_conf.border,
        -- TODO keymap to convert style to Float
        focusable = false,
        zindex = 100,
    }
    if cursor_conf.style == 'fixed' then
        opts.width = cursor_conf.width
        opts.height = cursor_conf.height
    elseif cursor_conf.style == 'relative' then
        opts.width = (cursor_conf.width > 0 and conf.width < conf.max_width) and conf.width or conf.max_width
        opts.height = (cursor_conf.height > 0 and conf.height < conf.max_height) and conf.height or conf.max_height
    else
        error('unknown style!')
    end
    return opts
end

M.float_opts = get_float_opts(conf.float)

M.cursor_opts = get_cursor_opts(conf.cursor)

return M
