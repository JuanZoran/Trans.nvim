local M = {}

M.component = function(field)
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
        for trans in vim.gsplit(field.translation, '\n', true) do
            table.insert(translations, trans)
        end

        return { ref, translations }
    end
end

return M
