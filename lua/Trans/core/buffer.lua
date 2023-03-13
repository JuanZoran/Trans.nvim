---@class buf
---@field bufnr integer buffer handle
local buffer = {}

local api, fn = vim.api, vim.fn

---Clear all content in buffer
function buffer:wipe()
    api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
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

---Destory buffer
function buffer:destory()
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

---Add Extmark to buffer
---@param linenr number line number should be set[one index]
---@param col_start number column start
---@param col_end number column end
---@param hl_group string highlight group
---@param ns number? highlight namespace
function buffer:add_extmark(linenr, col_start, col_end, hl_group, ns)
    linenr = linenr and linenr - 1 or -1
    api.nvim_buf_set_extmark(self.bufnr, ns or -1, linenr, col_start, {
        end_line = linenr,
        end_col = col_end,
        hl_group = hl_group,
    })
end

---Add highlight to buffer
---@param linenr number line number should be set[one index]
---@param col_start number column start [zero index]
---@param col_end number column end
---@param hl_group string highlight group
---@param ns number? highlight namespace
function buffer:add_highlight(linenr, hl_group, col_start, col_end, ns)
    linenr = linenr and linenr - 1 or -1
    col_start = col_start or 0
    api.nvim_buf_add_highlight(self.bufnr, ns or -1, hl_group, linenr, col_start, col_end or -1)
end

---Calculate buffer content display height
---@param width integer
---@return integer height
function buffer:height(width)
    local lines = self:lines()
    local height = 0
    for _, line in ipairs(lines) do
        height = height + math.max(1, (math.ceil(line:width() / width)))
    end
    return height
end

---Get buffer line count
---@return integer
function buffer:line_count()
    return api.nvim_buf_line_count(self.bufnr)
end

---Set line content
---@param nodes string|table|table[] string -> as line content | table -> as a node | table[] -> as node[]
---@param linenr number? line number should be set[one index] or let it be nil to append
function buffer:setline(nodes, linenr)
    linenr = linenr and linenr - 1 or -1

    if type(nodes) == 'string' then
        api.nvim_buf_set_lines(self.bufnr, linenr, linenr, false, { nodes })
    elseif type(nodes) == 'table' then
        if type(nodes[1]) == 'string' then
            -- FIXME :set [nodes] type as node
            ---@diagnostic disable-next-line: assign-type-mismatch
            api.nvim_buf_set_lines(self.bufnr, linenr, linenr, false, { nodes[1] })
            nodes:render(self, linenr, 0)
        else
            local strs = {}
            local num = #nodes
            for i = 1, num do
                strs[i] = nodes[i][1]
            end

            api.nvim_buf_set_lines(self.bufnr, linenr, linenr, false, { table.concat(strs) })
            local col = 0
            for i = 1, num do
                local node = nodes[i]
                node:render(self, linenr, col)
                col = col + #node[1]
            end
        end
    end
end

---@private
buffer.__index = function(self, key)
    local res = buffer[key]
    if res then
        return res
    elseif type(key) == 'number' then
        -- return fn.getbufoneline(self.bufnr, key) -- Vimscript Function Or Lua API ??
        return api.nvim_buf_get_lines(self.bufnr, key - 1, key, true)[1]
    else
        error('invalid key' .. key)
    end
end


---@private
buffer.__newindex = function(self, key, nodes)
    if type(key) == 'number' then
        self:setline(nodes, key)
    else
        rawset(self, key, nodes)
    end
end

---buffer constructor
---@return buf
function buffer.new()
    local new_buf = setmetatable({
        bufnr = api.nvim_create_buf(false, false),
        extmarks = {},
    }, buffer)


    new_buf:set('filetype', 'Trans')
    new_buf:set('buftype', 'nofile')
    return new_buf
end

return buffer
