local item_meta = {
    render = function(self, buffer, line, col)
        if self[2] then
            buffer:add_highlight(line, self[2], col, col + #self[1])
        end
    end,
}

local text_meta = {
    render = function(self, buffer, line, col)
        local items = self.items
        local step  = self.step or ""
        local len   = #step

        for i = 1, self.size do
            local item = items[i]
            item:render(buffer, line, col)
            col = col + #item[1] + len
        end
    end,
}

item_meta.__index = item_meta
text_meta.__index = function(self, key)
    return text_meta[key] or (key == 1 and table.concat(self.strs, self.step) or nil)
end

local function item(text, highlight)
    return setmetatable({
        [1] = text,
        [2] = highlight,
    }, item_meta)
end

local function text(items)
    local strs = {}
    local size = #items
    assert(size > 1)
    for i = 1, size do
        strs[i] = items[i][1]
    end

    return setmetatable({
        strs = strs,
        size = size,
        items = items,
    }, text_meta)
end

local function format(opts)
    local str   = opts.text
    local size  = str.size
    local width = opts.width
    local spin  = opts.spin or " "

    local wid = str[1]:width()
    local space = math.max(math.floor((width - wid) / (size - 1)), 0)
    if space > 0 then
        str.step = spin:rep(space)
    end
    return str
end

---@type table<string, function>
return {
    item = item,
    text = text,
    format = format,
    conjunction = function(str)
        return {
            item("", "TransTitleRound"),
            item(str, "TransTitle"),
            item("", "TransTitleRound"),
        }
    end,
}
