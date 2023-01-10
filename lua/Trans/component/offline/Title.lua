local M = {}

local display = require("Trans.conf.loader").loaded_conf.ui.display
local icon = require("Trans.conf.loader").loaded_conf.ui.icon

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


-- local data = {
--     { word, 'TransWord' },
--     -- NOTE :如果平配置设置显示，并且数据库中存在则有以下字段
--     { phonetic, 'TransPhonetic' },
--     collins,
--     oxford
--     -- { phonetic, 'TransPhonetic' },
-- }


---@alias items
---| 'string[]'       # 所有组件的信息
---| 'needformat?'# 是否需要格式化
---| 'highlight?' # 整个组件的高亮
---| 'indent?'    # 每行整体的缩进
---@alias component items[]
---从查询结果中获取字符串
---@param field table 查询的结果
---@return component component 提取的组件信息[包含多个组件]
M.component = function(field)
    local component = {}
    local data = {
        { field.word, 'TransWord' },
    }

    if display.phnoetic and field.phonetic and field.phonetic ~= '' then
        table.insert(
            data,
            { '[' .. field.phonetic .. ']', 'TransPhonetic' }
        )
    end

    if display.collins and field.collins then
        table.insert(data, {
            icon.star:rep(field.collins)
        })
    end

    if display.oxford and field.oxford then
        table.insert(data,
            { field.oxford == 1 and icon.isOxford or icon.notOxford, }
        )
    end

    component[1] = data
    return component
end

return M
