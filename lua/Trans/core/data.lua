local Trans = require 'Trans'

---@class TransData: TransDataOption
---@field mode string @The mode of the str
---@field from string @Source language type
---@field to string @Target language type
---@field str string @The original string
---@field result table<string, TransResult|nil|false> @The result of the translation
---@field frontend TransFrontend
---@field is_word? boolean @Is the str a word
---@field trace table<string, string> debug message
---@field backends TransBackend[]
local M = {}
M.__index = M

---TransData constructor
---@param opts TransDataOption
---@return TransData
function M.new(opts)

    ---@cast opts TransData
    local mode     = opts.mode
    opts.result    = {}
    opts.trace     = {}
    local strategy = Trans.conf.strategy[mode]


    ---@cast opts TransData
    setmetatable(opts, M)


    -- NOTE : whether should we use the default strategy
    opts.frontend = Trans.frontend[strategy.frontend].new()
    opts.backends = {}

    return opts
end

---@class TransResult
---@field str? string? @The original string
---@field title table | string @table: {word, phonetic, oxford, collins}
---@field tag string[]? @array of tags
---@field pos table<string, string>? @table: {name, value}
---@field exchange table<string, string>? @table: {name, value}
---@field definition? string[]? @array of definitions
---@field translation? string[]? @array of translations
---@field web? table<string, string[]>[]? @web definitions
---@field explains? string[]? @basic explains


---Get the first available result [return nil if no result]
---@return TransResult | false?
---@return string? backend.name
function M:get_available_result()
    local result = self.result
    for _, backend in ipairs(self.backends) do
        if result[backend.name] then
            return result[backend.name], backend.name
        end
    end
end

---@class Trans
---@field data TransData
return M
