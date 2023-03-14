local node = require('Trans').util.node
local it, t, f = node.item, node.text, node.format

local function conjunction(text)
    return {
        it('', 'TransTitleRound'),
        it(text, 'TransTitle'),
        it('', 'TransTitleRound'),
    }
end

local interval = (' '):rep(4)

local strategy = {
    title = function(hover, title)
        if type(title) == 'string' then
            hover.buffer:setline(it(title, 'TransWord'))
            return
        end

        local icon = hover.opts.icon


        local word     = title.word
        local oxford   = title.oxford
        local collins  = title.collins
        local phonetic = title.phonetic


        if not phonetic and not collins and not oxford then
            hover.buffer:setline(it(word, 'TransWord'))
        else
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
        end
    end,
    tag = function(hover, tag)
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
    exchange = function(hover, exchange)
        local buffer = hover.buffer
        buffer:setline(conjunction('词形变化'))

        for description, value in pairs(exchange) do
            buffer:setline(
                it(interval .. description .. interval .. value, 'TransExchange')
            )
        end

        buffer:setline('')
    end,
    pos = function(hover, pos)
        local buffer = hover.buffer
        buffer:setline(conjunction('词性'))

        for description, value in pairs(pos) do
            buffer:setline(
                it(interval .. description .. interval .. value, 'TransPos')
            )
        end

        buffer:setline('')
    end,
    translation = function(hover, translation)
        local buffer = hover.buffer
        buffer:setline(conjunction('中文翻译'))

        for _, value in ipairs(translation) do
            buffer:setline(
                it(interval .. value, 'TransTranslation')
            )
        end

        buffer:setline('')
    end,
    definition = function(hover, definition)
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




---@class TransHover
---@field load fun(hover: TransHover, result: TransResult, field: string)
return function(hover, result, field)
    strategy[field](hover, result[field])
end
