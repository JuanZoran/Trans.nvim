---@class iCiba: TransBackend
---@field uri string api uri
---@field salt string
---@field app_id string
---@field app_passwd string
---@field disable boolean
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
function M.get_content(data)
    return {
        word = data.str,
        is_need_mean = '1',
        m = 'getsuggest',
        c = 'word',
    }
end

---@overload fun(TransData): TransResult
function M.query(data)
    local handle = function(res)
        local status, body = pcall(vim.json.decode, res.body)
        vim.print(body)

        if true and not status or not body or body.errorCode ~= "0" then
            data.result.iciba = false
            data[#data + 1] = res
            return
        end

        -- if not body.isWord then
        --     data.result.youdao = {
        --         title = body.query,
        --         [data.from == 'en' and 'translation' or 'definition'] = body.translation,
        --     }
        --     return
        -- end

        -- local tmp = {
        --     title    = {
        --         word     = body.query,
        --         phonetic = body.basic.phonetic,
        --     },
        --     web      = body.web,
        --     explains = body.basic.explains,
        --     -- phrases                                               = body.phrases,
        --     -- synonyms                                              = body.synonyms,
        --     -- sentenceSample                                        = body.sentenceSample,


        --     [data.from == 'en' and 'translation' or 'definition'] = body.translation,
        -- }
        -- data.result.iciba = tmp
    end

    require('Trans').curl.get(M.uri, {
        query = M.get_content(data),
        callback = handle,
    })
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
