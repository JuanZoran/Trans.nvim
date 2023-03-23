local api, fn = vim.api, vim.fn


--- INFO :Define plugin command
local Trans = require("Trans")
local command = api.nvim_create_user_command

command("Translate", function()
    Trans.translate()
end, { desc = "  Translate cursor word" })


command("TranslateInput", function()
    Trans.translate({ mode = 'i' })
end, { desc = "  Translate input word" })

command("TransPlay", function()
    local util = Trans.util
    local str = util.get_str(vim.fn.mode())
    if str and str ~= "" and util.is_English(str) then
        str:play()
    end
end, { desc = " Auto play" })


string.width = api.nvim_strwidth

local f =
    fn.has('linux') == 1 and ([[echo %q | festival --tts]])
    or fn.has('mac') == 1 and ([[say %q]])
    or 'node' .. Trans.relative_path { 'tts', 'say.js' } .. ' %q'
string.play = function(self)
    fn.jobstart(f:format(self))
end
