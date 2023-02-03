local api = vim.api
local fn = vim.fn

local buffer = {
    addline = function(self, nodes, index)
        local size = self.size
        if index then
            assert(index <= size + 1)
            index = index
        else
            index = size + 1
        end
        local append = index == size + 1
        local line = index - 1
        if type(nodes) == 'string' then
            self[index] = nodes

        else
            local bufnr = self.bufnr
            local col = 0
            if type(nodes[1]) == 'string' then
                self[index] = nodes[1]
                nodes:load(bufnr, line, col)

            else
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
        end
        if append then
            self.size = self.size + 1
        end
    end,

    del = function(self, _start, _end)
        if not _start then
            fn.deletebufline(self.bufnr, '$')
        else
            _end = _end or _start
            fn.deletebufline(self.bufnr, _start, _end)
        end
        self.size = api.nvim_buf_line_count(self.bufnr)
    end,

    set = function(self, name, option)
        api.nvim_buf_set_option(self.bufnr, name, option)
    end,

    option = function(self, name)
        return api.nvim_buf_get_option(self.bufnr, name)
    end,

    is_valid = function(self)
        return api.nvim_buf_is_valid(self.bufnr)
    end,

    delete = function(self)
        api.nvim_buf_delete(self.bufnr, { force = true })
    end,

    len = function(self)
        return api.nvim_buf_line_count(self.bufnr) - 1
    end,

    map = function(self, key, operation)
        vim.keymap.set('n', key, operation, {
            buffer = self.bufnr,
            silent = true,
        })
    end,

    normal = function(self, key)
        api.nvim_buf_call(self.bufnr, function()
            vim.cmd([[normal! ]] .. key)
        end)
    end,

    lines = function(self, i, j)
        i = i and i - 1 or 0
        j = j and j - 1 or -1
        return api.nvim_buf_get_lines(self.bufnr, i, j, false)
    end,

    height = function(self, opts)
        local width = opts.width
        local wrap = opts.wrap or false

        local lines = self:lines()
        local size = #lines

        if wrap then
            local height = 0
            for i = 1, size do
                height = height + math.max(1, (math.ceil(lines[i]:width() / width)))
            end
            return height
        else
            return size
        end
    end,

    init = function(self)
        self.bufnr = api.nvim_create_buf(false, false)
        self:set('filetype', 'Trans')
        self:set('buftype', 'nofile')
        self.size = 0
    end,
}

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

buffer.__newindex = function(self, key, text)
    assert(key <= self.size + 1)
    fn.setbufline(self.bufnr, key, text)
end


return function()
    return setmetatable({
        bufnr = -1,
        size = 0,
    }, buffer)
end
