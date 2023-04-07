local api, fn = vim.api, vim.fn

--- INFO :Define plugin command
local Trans = require 'Trans'
local command = api.nvim_create_user_command

command('Translate', function() Trans.translate() end,
    { desc = '  Translate cursor word' })


command('TranslateInput', function() Trans.translate { mode = 'i' } end,
    { desc = '  Translate input word' })

command('TransPlay', function()
    local util = Trans.util
    local str = util.get_str(vim.fn.mode())
    if str and str ~= '' and util.is_english(str) then
        str:play()
    end
end, { desc = ' Auto play' })


string.width = api.nvim_strwidth

local system = Trans.system
local f =
    system == 'mac' and 'say %q' or
    system == 'termux' and 'termux-tts-speak %q' or
    system == 'linux' and 'echo %q | festival --tts' or
    'node' .. Trans.relative_path { 'tts', 'say.js' } .. ' %q'
-- 'powershell -Command "Add-Type –AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak([Console]::In.ReadToEnd())" | Out-File -Encoding ASCII %q'
-- or 'node' .. Trans.relative_path { 'tts', 'say.js' } .. ' %q'
-- system == 'win' and 'powershell -Command "Add-Type –AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak([Console]::In.ReadToEnd())" | Out-File -Encoding ASCII %q'

string.play = function(self)
    fn.jobstart(f:format(self))
end
