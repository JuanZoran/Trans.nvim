local m_window
local m_result
local m_content


local function set_title()
    local title = m_window.contents[1]
    local github = '  https://github.com/JuanZoran/Trans.nvim'

    title:center_line(github, '@text.uri')
end

local action = {
    quit = function()
        m_window:try_close()
    end,
}


local handle = {
    title = function()
        -- TODO :
    end,
}

return function(word)
    -- TODO :online query
    local float = require('Trans').conf.float
    m_result    = require('Trans.query.offline')(word)

    local opt = {
        relative = 'editor',
        width    = float.width,
        height   = float.height,
        border   = float.border,
        title    = float.title,
        row      = bit.rshift((vim.o.lines - float.height), 1),
        col      = bit.rshift((vim.o.columns - float.width), 1),
        zindex   = 50,
    }

    m_window           = require('Trans.window')(true, opt)
    m_window.animation = float.animation

    set_title()

    m_content = m_window.contents[2]
    for _, proc in pairs(handle) do
        proc()
    end

    m_window:draw()
    m_window:open()
    m_window:bufset('bufhidden', 'wipe')

    for act, key in pairs(float.keymap) do
        m_window:map(key, action[act])
    end
end
