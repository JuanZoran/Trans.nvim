---@class buf
---@field bufnr integer buffer handle
---@field size integer buffer line count
local buffer = {}

local api, fn = vim.api, vim.fn

---Clear all content in buffer
function buffer:wipe()
    api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
    self.size = 0
end

---delete buffer [_start, _end] line content [one index]
---@param _start integer start line index
---@param _end integer end line index
function buffer:del(_start, _end)
    if not _start then
        fn.deletebufline(self.bufnr, '$')
    else
        _end = _end or _start
        fn.deletebufline(self.bufnr, _start, _end)
    end
    self.size = api.nvim_buf_line_count(self.bufnr)
end

---Set buffer option
---@param name string option name
---@param value any option value
function buffer:set(name, value)
    api.nvim_buf_set_option(self.bufnr, name, value)
end

---get buffer option
---@param name string option name
---@return any
function buffer:option(name)
    return api.nvim_buf_get_option(self.bufnr, name)
end

function buffer:delete()
    api.nvim_buf_delete(self.bufnr, { force = true })
end

---Set buffer load keymap
---@param key string
---@param operation function | string
function buffer:map(key, operation)
    vim.keymap.set('n', key, operation, {
        buffer = self.bufnr,
        silent = true,
    })
end

---Execute normal keycode in this buffer[no recursive]
---@param key string key code
function buffer:normal(key)
    api.nvim_buf_call(self.bufnr, function()
        vim.cmd([[normal! ]] .. key)
    end)
end

---@return boolean
---@nodiscard
function buffer:is_valid()
    return api.nvim_buf_is_valid(self.bufnr)
end

---Get buffer [i, j] line content
---@param i integer? start line index
---@param j integer? end line index
---@return string[]
function buffer:lines(i, j)
    i = i and i - 1 or 0
    j = j and j - 1 or -1
    return api.nvim_buf_get_lines(self.bufnr, i, j, false)
end

---Calculate buffer content display height
---@param width integer
---@return integer height
function buffer:height(width)
    local size = self.size
    local lines = self:lines()
    local height = 0
    for i = 1, size do
        height = height + math.max(1, (math.ceil(lines[i]:width() / width)))
    end
    return height
end

---Add|Set line content
---@param nodes string|table|table[] string -> as line content | table -> as a node | table[] -> as node[]
---@param index number? line number should be set[one index]
function buffer:addline(nodes, index)
    local newsize = self.size + 1
    assert(index == nil or index <= newsize)
    index = index or newsize
    if index == newsize then
        self.size = newsize
    end

    if type(nodes) == 'string' then
        self[index] = nodes
        return
    end


    local line = index - 1
    local bufnr = self.bufnr
    local col = 0
    if type(nodes[1]) == 'string' then
        self[index] = nodes[1]
        nodes:load(bufnr, line, col)
        return
    end


    local strs = {}
    local num = #nodes
    for i = 1, num do
        strs[i] = nodes[i][1]
    end

    self[index] = table.concat(strs)
    for i = 1, num do
        local node = nodes[i]
        node:load(bufnr, line, col)
        col = col + #node[1]
    end
end

function buffer:init()
    self.bufnr = api.nvim_create_buf(false, false)
    self:set('filetype', 'Trans')
    self:set('buftype', 'nofile')
    self.size = 0
end

---@private
buffer.__index = function(self, key)
    local res = buffer[key]
    if res then
        return res

    elseif type(key) == 'number' then
        return fn.getbufoneline(self.bufnr, key)

    else
        error('invalid key' .. key)
    end
end

---@private
buffer.__newindex = function(self, key, text)
    assert(key <= self.size + 1)
    fn.setbufline(self.bufnr, key, text)
end

---buffer constructor
---@return buf
return function()
    return setmetatable({
        bufnr = -1,
        size = 0,
    }, buffer)
end
