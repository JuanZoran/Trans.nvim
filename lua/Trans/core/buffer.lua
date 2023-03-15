local api, fn = vim.api, vim.fn

---@class TransBuffer
---@field bufnr integer buffer handle
---@field [number] string buffer[line] content
local buffer = {}

---Clear all content in buffer
function buffer:wipe()
    api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
end

---Delete buffer [_start, _end] line content [one index]
---@param _start? integer start line index
---@param _end? integer end line index
function buffer:del(_start, _end)
    ---@diagnostic disable-next-line: cast-local-type
    _start = _start or '$'
    fn.deletebufline(self.bufnr, _start, _end)
end

---Set buffer option
---@param name string option name
---@param value any option value
function buffer:set(name, value)
    api.nvim_buf_set_option(self.bufnr, name, value)
end

---Get buffer option
---@param name string option name
---@return any
function buffer:option(name)
    return api.nvim_buf_get_option(self.bufnr, name)
end

---Destory buffer
function buffer:destroy()
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

---Execute keycode in normal this buffer[no recursive]
---@param key string key code
function buffer:normal(key)
    api.nvim_buf_call(self.bufnr, function()
        vim.cmd([[normal! ]] .. key)
    end)
end

---@nodiscard
---@return boolean
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
---@param hl_group string highlight group
---@param col_start? number column start [zero index]
---@param col_end? number column end
---@param ns number? highlight namespace
function buffer:add_highlight(linenr, hl_group, col_start, col_end, ns)
    -- vim.print(linenr, hl_group, col_start, col_end, ns)
    linenr = linenr - 1 or -1
    col_start = col_start or 0
    api.nvim_buf_add_highlight(self.bufnr, ns or -1, hl_group, linenr, col_start, col_end or -1)
end

---Get buffer line count
---@return integer
function buffer:line_count()
    return api.nvim_buf_line_count(self.bufnr)
end

---Set line content
---@param nodes string|table|table[] string -> as line content | table -> as a node | table[] -> as node[]
---@param one_index number? line number should be set[one index] or let it be nil to append
function buffer:setline(nodes, one_index)
    self:set('modifiable', true)


    ---@diagnostic disable-next-line: cast-local-type, param-type-mismatch
    one_index = one_index or self:line_count() + 1
    if one_index == 2 and self[1] == '' then one_index = 1 end
    ---@cast one_index integer

    if type(nodes) == 'string' then
        fn.setbufline(self.bufnr, one_index, nodes)
    else
        -- FIXME :set [nodes] type as node
        if type(nodes[1]) == 'string' then
            ---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
            fn.setbufline(self.bufnr, one_index, nodes[1])
            nodes:render(self, one_index, 0)
        else
            local strs = {}
            local num = #nodes
            for i = 1, num do
                strs[i] = nodes[i][1]
            end

            fn.setbufline(self.bufnr, one_index, table.concat(strs))
            local col = 0
            for i = 1, num do
                local node = nodes[i]
                node:render(self, one_index, col)
                col = col + #node[1]
            end
        end
    end

    self:set('modifiable', false)
end

buffer.__index = function(self, key)
    local res = buffer[key]
    if res then
        return res
    elseif type(key) == 'number' then
        return fn.getbufoneline(self.bufnr, key) -- Vimscript Function Or Lua API ??
        -- return api.nvim_buf_get_lines(self.bufnr, key - 1, key, true)[1]
    else
        error('invalid key: ' .. key)
    end
end


buffer.__newindex = function(self, key, nodes)
    if type(key) == 'number' then
        self:setline(nodes, key)
    else
        rawset(self, key, nodes)
    end
end


---@nodiscard
---TransBuffer constructor
---@return TransBuffer
function buffer.new()
    local new_buf = setmetatable({
        bufnr = api.nvim_create_buf(false, false),
    }, buffer)

    new_buf:set('modifiable', false)
    new_buf:set('filetype', 'Trans')
    new_buf:set('buftype', 'nofile')
    return new_buf
end

---@class Trans
---@field buffer TransBuffer
return buffer
