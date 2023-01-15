local M = {}
local conf = require('Trans').conf
local api = require('Trans.api')
local win = require('Trans.core.window')
local handler = require('Trans.core.handler')


local function get_select()
    local s_start = vim.fn.getpos("v")
    local s_end = vim.fn.getpos(".")
    if s_start[2] > s_end[2] or s_start[3] > s_end[3] then
        s_start, s_end = s_end, s_start
    end

    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return table.concat(lines, '')
end

local function get_word(method)
    if method == 'n' then
        return vim.fn.expand('<cword>')
    elseif method == 'v' then
        vim.api.nvim_input('<ESC>')
        return get_select()
    elseif method == 'input' then
        -- TODO Use Telescope with fuzzy finder
        ---@diagnostic disable-next-line: param-type-mismatch
        return vim.fn.input('请输入您要查询的单词: ')
    elseif method == 'last' then
        return win.show()
    else
        error('unknown method' .. method)
    end
end


M.translate = function(method, view)
    method = method or vim.api.nvim_get_mode().mode
    view = view or conf.view[method]
    local word = get_word(method)
    if word then
        win.init(view)
        local result = api.query('offline', word)
        local content = handler.process(view, result)
        win.draw(content)
    end
end


return M
