local util = require('Trans').util

---@class TransNode
---@field [1] string text to be rendered
---@field render fun(self: TransNode, buffer: TransBuffer, line: number, col: number) render the node


---@class TransItem : TransNode
local item_meta = {
    ---@param self TransItem
    ---@param buffer TransBuffer
    ---@param line integer
    ---@param col integer
    render = function(self, buffer, line, col)
        if self[2] then
            buffer:add_highlight(line, self[2], col, col + #self[1])
        end
    end,
}

---@class TransText : TransNode
---@field step string
---@field nodes TransNode[]
local text_meta = {
    ---@param self TransText
    ---@param buffer TransBuffer
    ---@param line integer
    ---@param col integer
    render = function(self, buffer, line, col)
        local nodes = self.nodes
        local step  = self.step
        local len   = step and #step or 0

        for _, node in ipairs(nodes) do
            node:render(buffer, line, col)
            col = col + #node[1] + len
        end
    end,
}

item_meta.__index = item_meta
text_meta.__index = text_meta


---Basic item node
---@param tuple {[1]: string, [2]: string?}
---@return TransItem
local function item(tuple)
    return setmetatable(tuple, item_meta)
end



---@param nodes {[number]: TransNode, step: string?}
---@return TransText
local function text(nodes)
    return setmetatable({
        [1]   = table.concat(util.list_fields(nodes, 1), nodes.step),
        step  = nodes.step,
        nodes = nodes,
    }, text_meta)
end


---@param args {[number]: TransNode, width: integer, spin: string?}
---@return TransText
local function format(args)
    local width = args.width
    local spin  = args.spin or " "
    local size  = #args
    local wid   = 0
    for i = 1, size do
        wid = wid + args[i][1]:width()
    end


    local space = math.max(math.floor((width - wid) / (size - 1)), 0)
    args.step   = spin:rep(space)
    args.width  = nil
    args.spin   = nil

    ---@diagnostic disable-next-line: param-type-mismatch
    return text(args)
end


---@class TransUtil
---@field node TransNodes


---@class TransNodes
return {
    item = item,
    text = text,
    format = format,
    conjunction = function(str)
        return {
            item { "", "TransTitleRound" },
            item { str, "TransTitle" },
            item { "", "TransTitleRound" },
        }
    end,
}
