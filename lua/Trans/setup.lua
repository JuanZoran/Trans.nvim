if vim.fn.executable('sqlite3') ~= 1 then
    error('Please check out sqlite3')
end

vim.api.nvim_create_user_command('Translate', function ()
    require("Trans").translate()
end, {
    desc = '  单词翻译',
})

vim.api.nvim_create_user_command('TranslateInput', function ()
    require("Trans").translate {
        method = 'input',
    }
end, {desc = '  搜索翻译'})

-- TODO 
-- vim.api.nvim_create_user_command('TranslateHistory', require("Trans.core").query_input, {
--     desc = '翻译输入的单词',
-- })

local highlights = require("Trans.conf.loader").loaded_conf.ui.highlight
for highlight, opt in pairs(highlights) do
    vim.api.nvim_set_hl(0, highlight, opt)
end
