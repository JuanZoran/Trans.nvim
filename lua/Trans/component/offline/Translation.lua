local M = {}

M.component = function(field, max_size)
    if field.translation then
        local ref = {
            { '中文翻译', 'TransRef' }
        }

        local translations = {
            highlight = 'TransTranslation',
            indent = 4,
            emptyline = true,
            needformat = true,
        }
        local size = 0
        for trans in vim.gsplit(field.translation, '\n', true) do
            size = size + 1
            table.insert(translations, trans)
            if size == max_size then 
                break
            end
        end

        return { ref, translations }
    end
end

return M
