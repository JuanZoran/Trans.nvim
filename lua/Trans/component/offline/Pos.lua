local M = {}

M.component = function(field)
    -- TODO
    if field.pos and field.pos ~= '' then
        local ref = {
            { '词性:', 'TransRef' },
        }
        local pos = {
            { field.pos },
            highlight = 'TransPos',
            indent = 4,
            emptyline = true,
        }

        return { ref, pos }
    end
end

return M
