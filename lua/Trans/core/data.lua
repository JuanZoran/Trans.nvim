local Trans = require('Trans')


---@class TransData
---@field from string @Source language type
---@field to string @Target language type
---@field is_word boolean @Is the str a word
---@field str string @The original string
---@field mode string @The mode of the str
---@field result table<string, TransResult|boolean> @The result of the translation
---@field frontend TransFrontend
---@field backends table<string, TransBackend>
local M = {}
M.__index = M

---TransData constructor
---@param opts table
---@return TransData
function M.new(opts)
    local mode = opts.mode
    local str  = opts.str


    local strategy = Trans.conf.strategy[mode]


    local data = setmetatable({
        str    = str,
        mode   = mode,
        result = {},
    }, M)


    data.frontend = Trans.frontend[strategy.frontend].new()
    data.backends = {}
    for i, name in ipairs(strategy.backend) do
        data.backends[i] = Trans.backend[name]
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

    return data
end

---@class TransResult
---@field title table | string @table: {word, phonetic, oxford, collins}
---@field tag string[]? @array of tags
---@field pos table<string, string>? @table: {name, value}
---@field exchange table<string, string>? @table: {name, value}
---@field definition? string[]? @array of definitions
---@field translation? string[]? @array of translations


---Get the first available result [return nil if no result]
---@return TransResult?
function M:get_available_result()
    local result = self.result
    local backend = self.backends

    for _, name in ipairs(backend) do
        if result[name] then
            return result[name]
        end
    end
end

---@class Trans
---@field data TransData
return M
