local M = {}

local display = require("Tran.conf").ui.display
-- Example:
-- local content = {
--     width = 1,
--     height = 1;
--     lines = {
--         Highlight = {
--             'first line',
--             'second line',
--         }
--     },   ---@table
-- }


-- local function format()
--     
-- end

M.to_content = function (field)
    -- TODO 
    local line = ''
    local format = '%s  %s %s %s'
    local content = {
        height = 1,
    }
    return content
end

return M
