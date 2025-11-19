---@class TransProgressUtil
local M = {}

---@param size number?
---@return string human readable size
function M.format_size(size)
    if not size or size <= 0 then
        return '0B'
    end

    local units = { 'B', 'K', 'M', 'G', 'T' }
    local value = size
    local index = 1
    while value >= 1024 and index < #units do
        value = value / 1024
        index = index + 1
    end

    return string.format('%.1f%s', value, units[index])
end

---@param downloaded number
---@param total number
---@return number? percentage (0-100)
function M.percent(downloaded, total)
    if not downloaded or not total or total <= 0 then
        return nil
    end

    local ratio = math.min(1, downloaded / total)
    return math.floor(ratio * 100)
end

return M
