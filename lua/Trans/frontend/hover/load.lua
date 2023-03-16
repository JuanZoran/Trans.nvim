local node = require('Trans').util.node
local it, t, f = node.item, node.text, node.format
local interval = (' '):rep(4)

local function conjunction(text)
    return {
        it('', 'TransTitleRound'),
        it(text, 'TransTitle'),
        it('', 'TransTitleRound'),
    }
end

---@type table<string, fun(hover:TransHover, result: TransResult)>
local default = {
    str = function(hover, result)
        -- TODO :
        hover.buffer:setline(it(result.str, 'TransWord'))
    end,
    translation = function(hover, result)
        local translation = result.translation
        if not translation then return end

        local buffer = hover.buffer
        buffer:setline(conjunction('中文翻译'))

        for _, value in ipairs(translation) do
            buffer:setline(
                it(interval .. value, 'TransTranslation')
            )
        end

        buffer:setline('')
    end,
    definition = function(hover, result)
        local definition = result.definition
        if not definition then return end

        local buffer = hover.buffer
        buffer:setline(conjunction('英文注释'))

        for _, value in ipairs(definition) do
            buffer:setline(
                it(interval .. value, 'TransDefinition')
            )
        end

        buffer:setline('')
    end,
}

---@diagnostic disable-next-line: assign-type-mismatch
default.__index = default

local strategy = setmetatable({}, {
    __index = function(tbl, key)
        tbl[key] = default
        return tbl[key]
    end,
    __newindex = function(tbl, key, value)
        rawset(tbl, key, setmetatable(value, default))
    end
})


strategy.offline = {
    title = function(hover, result)
        local title = result.title
        if not title then return end

        local icon     = hover.opts.icon

        local word     = title.word
        local oxford   = title.oxford
        local collins  = title.collins
        local phonetic = title.phonetic

        hover.buffer:setline(f {
            width = hover.opts.width,
            text = t {
                it(word, 'TransWord'),
                t {
                    it('['),
                    it((phonetic and phonetic ~= '') and phonetic or icon.notfound, 'TransPhonetic'),
                    it(']')
                },

                it(collins and icon.star:rep(collins) or icon.notfound, 'TransCollins'),
                it(oxford == 1 and icon.yes or icon.no)
            },
        })
    end,
    tag = function(hover, result)
        local tag = result.tag
        if not tag then return end

        local buffer = hover.buffer
        buffer:setline(conjunction('标签'))

        local size = #tag

        for i = 1, size, 3 do
            buffer:setline(
                it(
                    interval .. tag[i] ..
                    (tag[i + 1] and interval .. tag[i + 1] ..
                    (tag[i + 2] and interval .. tag[i + 2] or '') or ''),
                    'TransTag'
                )
            )
        end

        buffer:setline('')
    end,
    exchange = function(hover, result)
        local exchange = result.exchange
        if not exchange then return end

        local buffer = hover.buffer
        buffer:setline(conjunction('词形变化'))

        for description, value in pairs(exchange) do
            buffer:setline(
                it(interval .. description .. interval .. value, 'TransExchange')
            )
        end

        buffer:setline('')
    end,
    pos = function(hover, result)
        local pos = result.pos
        if not pos then return end

        local buffer = hover.buffer
        buffer:setline(conjunction('词性'))

        for description, value in pairs(pos) do
            buffer:setline(
                it(interval .. description .. interval .. value, 'TransPos')
            )
        end

        buffer:setline('')
    end,
}

-- FIXME :

---@class TransHover
---@field load fun(hover: TransHover, result: TransResult, name: string, order: string[])
return function(hover, result, name, order)
    order = order or { 'str', 'translation', 'definition' }

    local method = strategy[name]

    for _, field in ipairs(order) do
        method[field](hover, result)
    end
end
