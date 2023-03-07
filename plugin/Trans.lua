local M       = require("Trans")
local api     = vim.api
local command = api.nvim_create_user_command

command('Translate', function() M.translate() end, { desc = '  单词翻译', })
command('TranslateInput', function() M.translate('i') end, { desc = '  搜索翻译', })
command('TransPlay', function()
    local word = M.get_word(api.nvim_get_mode().mode)
    if word ~= '' and word:isEn() then
        word:play()
    end
end, { desc = ' 自动发音' })
