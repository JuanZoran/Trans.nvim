local M = {}

local display = require("Trans.conf.loader").loaded.conf.ui.display
local icon = require("Trans.conf.loader").loaded.conf.ui.icon

local m_field = {}
-- {
--   collins = 3,
--   definition = "n. an expression of greeting",
--   exchange = "s:hellos",
--   oxford = 1,
--   phonetic = "hə'ləʊ",
--   pos = "u:97/n:3",
--   tag = "zk gk",
--   translation = "n. 表示问候， 惊奇或唤起注意时的用语\nint. 喂；哈罗\nn. (Hello)人名；(法)埃洛",
--   word = "hello"
-- }


local content = {
    lines = {
        need_format = {
            {}, -- line
            {}, -- line
            {}, -- line
            {}, -- line
        }
    },
    highlight = {
        [2] = { -- 第几行第几个组件的高亮
            [1] = 'highlightname',
        },
    }
}

local function get_items()
    local items = {
        m_field.word,
    }
    if display.phonetic then
        table.insert(items, '[' .. m_field.phonetic .. ']')
    end

    if display.collins_star then
        table.insert(items, icon.star:rep(m_field.collins))
    end

    if display.oxford then
        local item
        if m_field.oxford and m_field.oxford == 1 then
            item = icon.isOxford
        else
            item = icon.notOxford
        end
        table.insert(items, item)
    end

    return items
end

M.content = function(field)
    -- TODO
    m_field = field or {}
    local content = {}


    content.lines = {
        need_format = {
            get_items()
        },
        highlight = {
            [1] = { -- 第一行
                'Trans',
            }
        }
    }
    return content
end

return M
