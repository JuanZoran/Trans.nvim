local api = vim.api
local ns = require('Trans').ns
local add_hl = api.nvim_buf_add_highlight

local item_meta = {
    load = function(self, bufnr, line, col)
        if self[2] then
            add_hl(bufnr, ns, self[2], line, col, col + #self[1])
        end
    end,
}

local text_meta = {
    load = function(self, bufnr, line, col)
        local items = self.items
        local step = self.step or ''
        local len = #step

        for i = 1, self.size do
            local item = items[i]
            item:load(bufnr, line, col)
            col = col + #item[1] + len
        end
    end
}

item_meta.__index = item_meta
text_meta.__index = function(self, key)
    local res = text_meta[key]
    if res then
        return res
    elseif key == 1 then
        return table.concat(self.strs, self.step)
    end
end

return {
    item = function(text, highlight)
        return setmetatable({
            [1] = text,
            [2] = highlight,
        }, item_meta)
    end,

    text = function(items)
        local strs = {}
        local size = #items
        assert(size > 1)
        for i = 1, size do
            strs[i] = items[i][1]
        end

        return setmetatable({
            strs  = strs,
            size  = size,
            items = items,
        }, text_meta)
    end,

    format = function(opts)
        local text  = opts.text
        local size  = text.size
        local width = opts.width
        local spin  = opts.spin or ' '

        local wid   = text[1]:width()
        local space = math.max(math.floor((width - wid) / (size - 1)), 0)
        if space > 0 then
            text.step = spin:rep(space)
        end
        return text
    end,
}
