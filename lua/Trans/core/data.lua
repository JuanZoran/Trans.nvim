local Trans = require('Trans')

local M = {}
M.__index = M



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

return M
