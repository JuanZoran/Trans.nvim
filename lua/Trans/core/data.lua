local Trans = require('Trans')

local M = {}
M.__index = M

---@class data
---@field str string
---@field mode string
---@field result table
---@field frontend table
---@field backend table
---@field from string
---@field to string
---@field is_word boolean


---Data constructor
---@param opts table
---@return data
function M.new(opts)
    local mode = opts.mode
    local str  = opts.str


    local strategy = Trans.conf.strategy[mode]
    local data     = {
        str    = str,
        mode   = mode,
        result = {},
    }

    data.frontend  = Trans.frontend[strategy.frontend].new()

    data.backend   = {}
    for i, name in ipairs(strategy.backend) do
        data.backend[i] = Trans.backend[name]
    end


    if Trans.util.is_English(str) then
        data.from = 'en'
        data.to = 'zh'
    else
        data.from = 'zh'
        data.to = 'en'
    end

    -- FIXME : Check if the str is a word
    data.is_word = true

    return setmetatable(data, M)
end

---Get the first available result [return nil if no result]
---@return table?
function M:get_available_result()
    local result = self.result
    local backend = self.backend

    for _, name in ipairs(backend) do
        if result[name] then
            return result[name]
        end
    end
end

return M
