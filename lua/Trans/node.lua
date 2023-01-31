-- NOTE : 设置content的node
local item_load = function(self, content, line, col)
    if self.hl then
        content:newhl {
            name = self.hl,
            line = line,
            _start = col,
            _end = col + #self.text,
        }
    end
end

return {
    item = function(text, hl)
        return {
            text = text,
            hl = hl,
            load_hl = item_load,
        }
    end,

    text = function(...)
        local items = { ... }
        local strs = {}
        for i, item in ipairs(items) do
            strs[i] = item.text
        end

        return {
            text = table.concat(strs),
            load_hl = function(_, content, line, col)
                for _, item in ipairs(items) do
                    item:load_hl(content, line, col)
                    col = col + #item.text
                end
            end
        }
    end,
}
