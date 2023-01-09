local M = {}
M.__index = M
M.len = 0

function M:new()
    local items = {}
    setmetatable(items, self)
    return items
end

function M:insert(item, highlight)
    table.insert(self, item)
    self.len = self.len + #item
end

function M:format(win_width)

end

return M
