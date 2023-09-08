---@class Trans
---@field debug fun(message: string, level: number?)

return function (message, level)
    level = level or vim.log.levels.INFO
    -- TODO : custom messaage filter
    vim.notify(message, level)
end
