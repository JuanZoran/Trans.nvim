local node = require('Trans').util.node
local it, t, f, co = node.item, node.text, node.format, node.conjunction
local interval = (' '):rep(4)

---@type TransHoverRenderer
local M = {}

function M.tag(hover, result)
    local tag = result.tag
    if not tag then return end

    local buffer = hover.buffer
    buffer:setline(co('标签'))

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
end

function M.exchange(hover, result)
    local exchange = result.exchange
    if not exchange then return end

    local buffer = hover.buffer
    buffer:setline(co('词形变化'))

    for description, value in pairs(exchange) do
        buffer:setline(
            it(interval .. description .. interval .. value, 'TransExchange')
        )
    end

    buffer:setline('')
end

function M.pos(hover, result)
    local pos = result.pos
    if not pos then return end

    local buffer = hover.buffer
    buffer:setline(co('词性'))

    for description, value in pairs(pos) do
        buffer:setline(
            it(interval .. description .. interval .. value, 'TransPos')
        )
    end

    buffer:setline('')
end

function M.title(hover, result)
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
end

return M
