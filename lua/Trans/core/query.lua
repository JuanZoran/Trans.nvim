local type_check = require("Trans.util.debug").type_check
local query = require("Trans.api").query

local function get_select()
    local s_start = vim.fn.getpos("v")
    local s_end = vim.fn.getpos(".")
    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return table.concat(lines, '\n')
end

local query_wrapper = function(opts)
    type_check {
        opts = { opts, 'table' },
        ['opts.method'] = { opts.method, 'string' },
    }

    local word = ''

    if opts.method == 'input' then
        ---@diagnostic disable-next-line: param-type-mismatch
        word = vim.fn.input('请输入您要查询的单词:') -- TODO Use Telescope with fuzzy finder

    elseif opts.method == 'n' then
        word = vim.fn.expand('<cword>')

    elseif opts.method == 'v' then
        word = get_select()
        -- TODO : other method
    else
        error('invalid method' .. opts.method)
    end

    return query(word)
end

return query_wrapper
