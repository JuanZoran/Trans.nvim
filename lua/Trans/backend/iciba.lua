---@class iCiba: TransOnlineBackend
local M = {
    uri  = 'https://dict-mobile.iciba.com/interface/index.php',
    name = 'iciba',
}

---@class iCibaQuery
---@field q string
---@field from string
---@field to string
---@field appid string
---@field salt string
---@field sign string
function M.get_query(data)
    return {
        word = data.str,
        is_need_mean = '1',
        m = 'getsuggest',
        c = 'word',
    }
end

function M.formatter(body, data)
    print 'TODO'
    -- if true and not status or not body or body.errorCode ~= "0" then
    --     data.result.iciba = false
    --     data[#data + 1] = res
    --     return
    -- end
end

-- {
--   message = { {
--       key = "测试",
--       means = { {
--           means = { "test", "testing", "checkout", "measurement " },
--           part = ""
--         } },
--       paraphrase = "test;testing;measurement ;checkout",
--       value = 0
--     } },
--   status = 1
-- }


return M
