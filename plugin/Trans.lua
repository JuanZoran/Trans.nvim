local api = vim.api


local M = require('Trans')
local new_command = api.nvim_create_user_command
new_command('Translate', function() M.translate() end, { desc = '  单词翻译', })
new_command('TranslateInput', function() M.translate('i') end, { desc = '  搜索翻译', })
new_command('TransPlay', function()
    local word = M.get_word(api.nvim_get_mode().mode)
    if word ~= '' and word:isEn() then
        word:play()
    end
end, { desc = ' 自动发音' })
