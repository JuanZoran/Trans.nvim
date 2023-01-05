if vim.fn.executable('sqlite3') ~= 1 then
    error('Please check out sqlite3')
end

vim.api.nvim_create_user_command('TranslateCursorWord', require("Trans.core").query_cursor, {
    desc = '翻译光标下的单词',
})
vim.api.nvim_create_user_command('TranslateSelectWord', require("Trans.core").query_select, {
    desc = '翻译选中的单词',
})
vim.api.nvim_create_user_command('TranslateInputWord', require("Trans.core").query_input, {
    desc = '翻译输入的单词',
})

local highlights = require("Trans.conf").ui.highligh
for highlight, opt in pairs(highlights) do
    vim.nvim_set_hl(0, highlight, opt)
end
