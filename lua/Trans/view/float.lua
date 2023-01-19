local conf = require('Trans').conf

local m_window
local m_result


return function(word)
    -- TODO :online query
    m_result       = require('Trans.query.offline')(word)
    m_window       = require('Trans.window')
    local float    = conf.window.float
    float.row      = math.floor((vim.o.lines - float.height) / 2)
    float.col      = math.floor((vim.o.columns - float.width) / 2)
    float.relative = 'editor'

    -- 创建窗口
    m_window.init(true, float)
    m_window.center('https:github.com/JuanZoran/Trans.nvim', '@text.uri') -- only show color with treesiter
    m_window.draw()
    m_window.map('q', function ()
        m_window.try_close(9)
    end)
end
