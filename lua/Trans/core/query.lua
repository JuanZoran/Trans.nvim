local type_check = require("Trans.util.debug").type_check
local query = require("Trans.api").query

local function get_select()
    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    if s_start[2] ~= s_start[2] then
        error('TODO: multiline translate')
    end
    local lin = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)[1]
    local word = string.sub(lin, s_start[3], s_end[3])
    return word
end

local query_wrapper = function(opts)
    type_check {
        opts = { opts, 'table' },
        ['opts.method'] = { opts.method, 'string' },
    }

    local word = ''

    if opts.method == 'input' then
        word = vim.fn.input('请输入您要查询的单词:') -- TODO Use Telescope with fuzzy finder

    elseif opts.method == 'n' then
        word = vim.fn.expand('<cword>')

    elseif opts.mehotd == 'v' then
        word = get_select()
        -- TODO : other method

    else
        error('invalid method' .. opts.method)
    end

    return query(word)
end

return query_wrapper
