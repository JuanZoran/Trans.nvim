local m_window
local m_result

local function set_title()
    local title = m_window.contents[1]
    local github = 'https://github.com/JuanZoran/Trans.nvim'

    -- TODO :config this
    title:center_line(github, '@text.uri')
end

local action = {
    quit = function()
        m_window:try_close()
    end,
}


return function(word)
    -- TODO :online query
    local float = require('Trans').conf.float
    m_result    = require('Trans.query.offline')(word)

    local opt          = {
        relative = 'editor',
        width    = float.width,
        height   = float.height,
        border   = float.border,
        title    = float.title,
        row      = math.floor((vim.o.lines - float.height) / 2),
        col      = math.floor((vim.o.columns - float.width) / 2),
    }
    m_window           = require('Trans.window')(true, opt)
    m_window.animation = float.animation

    set_title()
    m_window:draw()
    m_window:open()
    m_window:bufset('bufhidden', 'wipe')

    for act, key in pairs(float.keymap) do
        m_window:map(key, action[act])
    end
end
