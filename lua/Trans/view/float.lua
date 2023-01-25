local conf = require('Trans').conf
local m_window
local m_result
local m_content

local engine_map = {
    ['本地'] = 'offline',
    ['百度'] = 'baidu',
    ['有道'] = 'youdao',
}

local function set_tag_hl(name, status)
    local hl = conf.float.tag[status]
    m_window:set_hl(name, {
        fg = '#000000',
        bg = hl,
    })

    m_window:set_hl(name .. 'round', {
        fg = hl,
    })
end

local function set_title()
    local title = m_window.contents[1]
    local github = '  https://github.com/JuanZoran/Trans.nvim'

    local item = title.item_wrap

    title:addline(
        title:center(item(github, '@text.uri'))
    )

    local text = title.text_wrap
    local format = '%s(%d)'
    for i, engine_ch in ipairs(conf.float.engine) do
        local engine_us = engine_map[engine_ch]
        set_tag_hl(engine_us, 'wait')

        local round = engine_us .. 'round'
        title:addline(
            text(
                item('', round),
                item(format:format(engine_ch, i), engine_us),
                item('', round)
            )
        )
    end
end

local action = {
    quit = function()
        m_window:try_close()
    end,
}


local function process()
    
end

return function(word)
    -- TODO :online query
    local float = conf.float
    local engine_ch = '本地'
    local engine_us = engine_map[engine_ch]

    m_result = require('Trans.query.' .. engine_us)(word)

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

    m_window = require('Trans.window')(true, opt)
    m_window.animation = float.animation

    set_title()
    m_content = m_window.contents[2]

    if m_result then
        set_tag_hl(engine_us, 'success')
        process()
    else
        set_tag_hl(engine_us, 'fail')
    end

    m_window:draw()
    m_window:open()
    m_window:bufset('bufhidden', 'wipe')

    for act, key in pairs(float.keymap) do
        m_window:map(key, action[act])
    end
end
