-- NOTE : 设置content的node
local item_meta = {
    load_hl = function(self, content, line, col)
        if self.hl then
            content:newhl {
                name = self.hl,
                line = line,
                _start = col,
                _end = col + #self.text,
            }
        end
    end
}

local text_meta = {
    load_hl = function(self, content, line, col)
        for _, item in ipairs(self.items) do
            item:load_hl(content, line, col)
            col = col + #item.text
        end
    end,
}


return {
    item = function(text, hl)
        return setmetatable({
            text = text,
            hl = hl,
        }, { __index = item_meta })
    end,


    text = function(...)
        local items = { ... }
        local strs = {}

        for i, item in ipairs(items) do
            strs[i] = item.text
        end

        return setmetatable({
            text = table.concat(strs),
            items = items,
        }, { __index = text_meta })
    end,
}
