local fn, api = vim.fn, vim.api

---@class TransUtil
local M = require 'Trans'.metatable 'util'

---Get selected text
---@return string
function M.get_select()
    local _start = fn.getpos 'v'
    local _end = fn.getpos '.'

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
        return table.concat(lines, ' ')
    end
end

---Get selected text
---@return string
function M.get_lines()
  local _start = vim.fn.getpos 'v'
  local _end = vim.fn.getpos '.'

  if _start[2] > _end[2] then
    _start, _end = _end, _start
  end

  local s_row, e_row = _start[2], _end[2]

  if s_row == e_row then
    return vim.fn.getline(s_row)
  else
    local lines = vim.fn.getline(s_row, e_row)
    return table.concat(lines, " ")
  end
end

---Get Text which need to be translated
---@param mode string
---@return string
function M.get_str(mode)
    return ({
        n = function()
            return fn.expand '<cword>'
        end,
        v = function()
            api.nvim_input '<Esc>'
            return M.get_select()
        end,
        i = function()
            return fn.input '需要翻译的字符串: '
        end,
        V = function()
            api.nvim_input '<Esc>'
            return M.get_lines()
        end,
    })[mode]():match '^%s*(.-)%s*$'
end

---Puase coroutine for {ms} milliseconds
---@param ms integer
function M.pause(ms)
    assert(ms)
    local co = coroutine.running()
    vim.defer_fn(function()
        coroutine.resume(co)
    end, ms)
    coroutine.yield()
end

---Detect whether the string is English
---@param str string
---@return boolean
function M.is_english(str)
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

---Split text into paragraphs
---@param lines string[] text to be split
---@return string[][] paragraphs
function M.split_to_paragraphs(lines, opts)
    --- TODO :More options and better algorithm to detect paragraphs
    opts = opts or {}
    local paragraphs = {}
    local paragraph = {}
    for _, line in ipairs(lines) do
        if line == '' then
            paragraphs[#paragraphs + 1] = paragraph
            paragraph = {}
        else
            paragraph[#paragraph + 1] = line
        end
    end
    return paragraphs
end

---Get visible lines in the window or current window
---@param opts { winid: integer, height: integer }?
---@return string[]
function M.visible_lines(opts)
    opts                        = opts or {}

    -- TODO : Use getpos('w0') and getpos('w$') to get the visible lines
    -- INFO : don't calculate the height of statusline and cmdheight or winbar?
    local winid                 = opts.winid or 0
    local win_height            = opts.height or api.nvim_win_get_height(winid)
    local current_line          = api.nvim_win_get_cursor(winid)[1]
    local current_relative_line = vim.fn.winline()


    local _start = current_line - current_relative_line
    local _end   = _start + win_height - vim.o.cmdheight --[[ - 1 -- maybe 1 for statusline?? ]]

    return api.nvim_buf_get_lines(0, _start, _end, false)
end

---Detect whether the string is a word
---@param str string
---@return boolean
function M.is_word(str)
    return str:find '%W' == nil
end

---@param list any[]
---@param step table
---@return any[]
function M.list_concat(list, step)
    local size = #list
    local ret = { list[1] }
    if size <= 1 then return ret end
    for i = 2, size do
        ret[i * 2 - 2] = step
        ret[i * 2 - 1] = list[i]
    end
    -- FIXME : Use deepcopy step?
    return ret
end

---Get the field of the list
---@param list any[]
---@param field any
---@return any[]
function M.list_fields(list, field)
    local ret = {}
    for i, v in ipairs(list) do
        ret[i] = v[field]
    end
    return ret
end

---@class Trans
---@field util TransUtil
return M
