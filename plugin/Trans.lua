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
    (vim.fn.has 'wsl' == 1 or system == 'win') and
    'powershell.exe -Command "Add-Type -AssemblyName System.speech;(New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak(\\\"%s\\\")"' or
    system == 'mac' and 'say %q' or
    system == 'termux' and 'termux-tts-speak %q' or
    system == 'linux' and 'echo %q | festival --tts' or
    error 'Unsupported system'


string.play = function(self)
    ---@diagnostic disable-next-line: param-type-mismatch
    local s = string.gsub(self, '\"', ' ')
    fn.jobstart(f:format(s))
end
