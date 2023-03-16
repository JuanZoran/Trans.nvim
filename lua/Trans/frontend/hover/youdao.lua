local node = require('Trans').util.node
local it, t, f, co = node.item, node.text, node.format, node.conjunction

---@type TransHoverRenderer
local M = {}
local interval = (' '):rep(4)

function M.web(hover, result)
    if not result.web then return end
    local buffer = hover.buffer
    buffer:setline(co('网络释义'))

    for _, w in ipairs(result.web) do
        buffer:setline(it(
            --- TODO :Better format style
            interval .. w.key .. interval .. table.concat(w.value, ' | '),
            'TransWeb'
        ))
    end
    buffer:setline('')
end


function M.explains(hover, result)
    local explains = result.explains
    if not explains then return end
    local buffer = hover.buffer
    buffer:setline(co('基本释义'))


    for i = 1, #explains, 2 do
        buffer:setline(it(
            interval .. explains[i] ..
            (explains[i + 1] and interval .. explains[i + 1] or ''),
            'TransExplains'
        ))
    end
    buffer:setline('')
end

M.title = require('Trans').frontend.hover.offline.title

return M
