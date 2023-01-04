local db = require("Trans").db

vim.api.nvim_create_user_command('TranslateCursorWord', require("Trans.display").query_cursor, {
    desc = '翻译光标下的单词',
})
vim.api.nvim_create_user_command('TranslateSelectWord', require("Trans.display").query_select, {
    desc = '翻译选中的单词',
})
vim.api.nvim_create_user_command('TranslateInputWord', require("Trans.display").query_input, {
    desc = '翻译输入的单词',
})

vim.api.nvim_create_autocmd('VimLeavePre', {
    group = vim.api.nvim_create_augroup("Trans", { clear = true }),
    pattern = '*',
    callback = function()
        if db:isopen() then
            db:close()
        end
    end,
})

local highlights = require("Trans").conf.highlight
for highlight, opt in pairs(highlights) do
    vim.nvim_set_hl(0, highlight, opt)
end
