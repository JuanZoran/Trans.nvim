local Trans = require('Trans')

local fn, api = vim.fn, vim.api

---@class TransUtil
local M = require('Trans').metatable('util')


---Get selected text
---@return string
function M.get_select()
    local _start = fn.getpos("v")
    local _end = fn.getpos('.')

    if _start[2] > _end[2] or (_start[3] > _end[3] and _start[2] == _end[2]) then
        _start, _end = _end, _start
    end
    local s_row, s_col = _start[2], _start[3]
    local e_row, e_col = _end[2], _end[3]

    -- print(s_row, e_row, s_col, e_col)
    ---@type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local line = fn.getline(e_row)
    local uidx = vim.str_utfindex(line, math.min(#line, e_col))
    ---@diagnostic disable-next-line: param-type-mismatch
    e_col = vim.str_byteindex(line, uidx)


    if s_row == e_row then
        return line:sub(s_col, e_col)
    else
        local lines = fn.getline(s_row, e_row)
        local e = #lines
        lines[1] = lines[1]:sub(s_col)
        lines[e] = line:sub(1, e_col)
        return table.concat(lines)
    end
end

---Get Text which need to be translated
---@param mode TransMode
---@return string
function M.get_str(mode)
    if mode == 'n' or mode == 'normal' then
        return fn.expand('<cword>')
    elseif mode == 'v' or mode == 'visual' then
        api.nvim_input('<ESC>')
        return M.get_select()
    elseif mode == 'input' then
        return fn.expand('<cword>')
    else
        error('Unsupported mode' .. mode)
    end
end

---Puase coroutine for {ms} milliseconds
---@param ms integer
function M.pause(ms)
    local co = coroutine.running()
    vim.defer_fn(function()
        coroutine.resume(co)
    end, ms)
    coroutine.yield()
end

---Detect whether the string is English
---@param str string
---@return boolean
function M.is_English(str)
    local char = { str:byte(1, -1) }
    for i = 1, #str do
        if char[i] > 128 then
            return false
        end
    end
    return true
end

---Calculates the height of the text to be displayed
---@param lines string[] text to be displayed
---@param width integer width of the window
---@return integer height display height
function M.display_height(lines, width)
    local height = 0
    for _, line in ipairs(lines) do
        height = height + math.max(1, (math.ceil(line:width() / width)))
    end
    return height
end

---Calculates the width of the text to be displayed
---@param lines string[] text to be displayed
---@return integer width display width
function M.display_width(lines)
    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(line:width(), width)
    end
    return width
end

---Calculates the height and width of the text to be displayed
---@param lines string[] text to be displayed
---@param width integer width of the window
---@return { height: integer, width: integer } _ display height and width
function M.display_size(lines, width)
    local ds_height, ds_width = 0, 0
    for _, line in ipairs(lines) do
        local wid = line:width()
        ds_height = ds_height + math.max(1, (math.ceil(wid / width)))
        ds_width = math.max(wid, ds_width)
    end

    return { height = ds_height, width = ds_width }
end

---Center node utility function
---@param node string -- TODO :Node
---@param win_width integer window width
---@return string
function M.center(node, win_width)
    if type(node) == 'string' then
        local space = math.max(0, math.floor((win_width - node:width()) / 2))
        return string.rep(' ', space) .. node
    end

    local str = node[1]
    win_width = str:width()
    local space = math.max(0, math.floor((win_width - str:width()) / 2))
    node[1] = string.rep(' ', space) .. str
    return node
end

---Execute function in main loop
---@param func function function to be executed
function M.main_loop(func)
    local co = coroutine.running()
    vim.defer_fn(function()
        func()
        coroutine.resume(co)
    end, 0)
    coroutine.yield()
end


---@class Trans
---@field util TransUtil
return M
