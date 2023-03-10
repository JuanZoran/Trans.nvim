local api, fn = vim.api, vim.fn

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
local M = require('Trans')
local command = api.nvim_create_user_command

command('Translate', function() M.translate() end, { desc = '  单词翻译', })
command('TransPlay', function()
    local str = M.util.get_str(api.nvim_get_mode().mode)
    if str and str ~= '' and M.util.is_English(str) then
        str:play()
    end
end, { desc = ' 自动发音' })



--- INFO :Parse online engines config file
local path = vim.fn.expand("$HOME/.vim/dict/Trans.json")
local file = io.open(path, "r")
if file then
    local content = file:read("*a")
    file:close()
    local status, engines = pcall(vim.json.decode, content)
    assert(status, 'Unable to parse json file: ' .. path)

    engines = engines or {}
    for k, v in pairs(engines) do
        if not v.enable then
            engines[k] = nil
        end
    end

    M.conf.engines = engines
else
    M.conf.engines = {}
end

-- new_command('TranslateInput', function() M.translate { mode = 'i' } end, { desc = '  搜索翻译', })
