local api, fn = vim.api, vim.fn


string.width = api.nvim_strwidth
--- INFO :Define string play method
if fn.has('linux') == 1 then
    string.play = function(self)
        local cmd = ([[echo "%s" | festival --tts]]):format(self)
        fn.jobstart(cmd)
    end
elseif fn.has('mac') == 1 then
    string.play = function(self)
        local cmd = ([[say "%s"]]):format(self)
        fn.jobstart(cmd)
    end
else
    string.play = function(self)
        local seperator = fn.has('unix') and '/' or '\\'
        local file = debug.getinfo(1, "S").source:sub(2):match('(.*)lua') .. seperator .. 'tts' .. seperator .. 'say.js'
        fn.jobstart('node ' .. file .. ' ' .. self)
    end
end


--- INFO :Define plugin command
local Trans = require('Trans')
local command = api.nvim_create_user_command

command('Translate', function() Trans.translate() end, { desc = '  单词翻译', })
command('TransPlay', function()
    local str = Trans.util.get_str(api.nvim_get_mode().mode)
    if str and str ~= '' and Trans.util.is_English(str) then
        str:play()
    end
end, { desc = ' 自动发音' })
