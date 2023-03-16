---@class Youdao: TransBackend
---@field uri string api uri
---@field salt string
---@field app_id string
---@field app_passwd string
---@field disable boolean
local M = {
    uri  = 'https://openapi.youdao.com/api',
    salt = tostring(math.random(bit.lshift(1, 15))),
    name = 'youdao',
}

---@class YoudaoQuery
---@field q string
---@field from string
---@field to string
---@field appid string
---@field salt string
---@field sign string

---Get content for query
---@param data TransData
---@return YoudaoQuery
function M.get_content(data)
    local str     = data.str
    local app_id  = M.app_id
    local salt    = M.salt
    local curtime = tostring(os.time())
    local input   = #str > 20 and
        str:sub(1, 10) .. #str .. str:sub(-10) or str

    -- sign=sha256(应用ID+input+salt+curtime+应用密钥)；
    local hash    = app_id .. input .. salt .. curtime .. M.app_passwd
    local sign    = vim.fn.sha256(hash)


    return {
        q        = str,
        to       = data.from == 'zh' and 'en' or 'zh-CHS',
        from     = 'auto',
        signType = 'v3',
        appKey   = app_id,
        salt     = M.salt,
        curtime  = curtime,
        sign     = sign,
    }
end

-- {
--   dict = {
--     url = "yddict://m.youdao.com/dict?le=eng&q=shows+your+registers+on+%22+in+NORMAL+or+%3CC-r%3E+in+INSERT+mode"
--   },
--   errorCode = "0",
--   isWord = false,
--   l = "en2zh-CHS",
--   mTerminalDict = {
--     url = "https://m.youdao.com/m/result?lang=en&word=shows+your+registers+on+%22+in+NORMAL+or+%3CC-r%3E+in+INSERT+mode"
--   },
--   query = 'shows your registers on " in NORMAL or <C-r> in INSERT mode',
--   requestId = "9dddf583-1233-48a5-a9ca-f1d0324a5349",
--   speakUrl = "https://openapi.youdao.com/ttsapi?q=shows+your+registers+on+%22+in+NORMAL+or+%3CC-r%3E+in+INSERT+mode&langType=en-USA&sign=8A0B3742F4E9FA92D4B65F028E1A6008&salt=1678931340864&voice=4&format=mp3&appKey=1858465a8708c121&ttsVoiceStrict=false",
--   tSpeakUrl = "https://openapi.youdao.com/ttsapi?q=%E5%9C%A8%E6%AD%A3%E5%B8%B8%E6%88%96%3CC-r%3E%E6%8F%92%E5%85%A5%E6%A8%A1%E5%BC%8F%E4%B8%8B%E6%98%BE%E7%A4%BA%E4%BD%A0%E7%9A%84%E5%AF%84%E5%AD%98%E5%99%A8&langType=zh-CHS&sign=456E436DBEC35447D36157200FC5ACA7&salt=1678931340864&voice=4&format=mp3&appKey=1858465a8708c121&ttsVoiceStrict=false",
--   translation = { "在正常或<C-r>插入模式下显示你的寄存器" },
--   webdict = {
--     url = "http://mobile.youdao.com/dict?le=eng&q=shows+your+registers+on+%22+in+NORMAL+or+%3CC-r%3E+in+INSERT+mode"
--   }
-- }

-- {
--   basic = {
--     explains = { "normal", "regular", "normality" },
--     phonetic = "zhèng cháng"
--   },
--   dict = {
--     url = "yddict://m.youdao.com/dict?le=eng&q=%E6%AD%A3%E5%B8%B8"
--   },
--   errorCode = "0",
--   isWord = true,
--   l = "zh-CHS2en",
--   mTerminalDict = {
--     url = "https://m.youdao.com/m/result?lang=zh-CHS&word=%E6%AD%A3%E5%B8%B8"
--   },
--   query = "正常",
--   requestId = "a8a40c0e-0d3b-49d5-a8fe-b1cd211ff5db",
--   returnPhrase = { "正常" },
--   speakUrl = "https://openapi.youdao.com/ttsapi?q=%E6%AD%A3%E5%B8%B8&langType=zh-CHS&sign=164F6EFF2EFFC7626FB70DBCF796AE70&salt=1678931501049&voice=4&format=mp3&appKey=1858465a8708c121&ttsVoiceStrict=false",
--   tSpeakUrl = "https://openapi.youdao.com/ttsapi?q=normal&langType=en-USA&sign=6A0CF2EF076EA8D82453956B33F69A51&salt=1678931501049&voice=4&format=mp3&appKey=1858465a8708c121&ttsVoiceStrict=false",
--   translation = { "normal" },
--   web = { {
--       key = "正常",
--       value = { "normal", "ordinary", "normo", "regular" }
--     }, {
--       key = "正常利润",
--       value = { "normal profits" }
--     }, {
--       key = "邦交正常化",
--       value = { "normalize relations", "normalization of diplomatic relations" }
--     } },
--   webdict = {
--     url = "http://mobile.youdao.com/dict?le=eng&q=%E6%AD%A3%E5%B8%B8"
--   }
-- }


---@overload fun(TransData): TransResult
---Query Using Baidu API
---@param data TransData
function M.query(data)
    local handle = function(res)
        local status, body = pcall(vim.json.decode, res.body)
        if not status or not body then
            data.result.youdao = false
            data.trace = res
            return
        end

        if true then
            vim.print(body)
            return
        end

        -- TEST :whether multi result
        data.result.youdao = {
            ['title'] = body.src,
            [data.from == 'en' and 'translation' or 'definition'] = body.translation,
        }
    end

    require('Trans').curl.get(M.uri, {
        query = M.get_content(data),
        callback = handle,
    })
end

---@class TransBackend
---@field youdao Youdao
return M
-- local GET = require("Trans.util.curl").GET
-- return function(word)
--     local isEn = word:isEn()
--     local result = {}

--     local uri = ('https://v.api.aa1.cn/api/api-fanyi-yd/index.php?msg=%s&type=%d'):format(word, isEn and 2 or 1)
--     GET(uri, {
--         callback = function(str)
--             local ok, res = pcall(vim.json.decode, str)
--             if not ok or not res or not res.text or isEn and res.text:isEn() then
--                 result[1] = false
--                 return
--             end

--             result[1] = {
--                 title = { word = word },
--                 [isEn and 'translation' or 'definition'] = res.text,
--             }

--             if result.callback then
--                 result.callback(result[1])
--             end
--         end
--     })

--     return result
-- end

-- local youdao    = require("Trans").conf.engine.youdao
-- local uri       = 'https://openapi.youdao.com/api'
-- local salt      = tostring(math.random(bit.lshift(1, 15)))
-- local appid     = youdao.appid
-- local appPasswd = youdao.appPasswd

-- local post = require('Trans.util.curl').POST

-- local function get_field(word)
--     -- local to = isEn and 'zh-'
--     local len     = #word
--     local curtime = tostring(os.time())
--     local input   = len > 20 and
--         word:sub(1, 10) .. len .. word:sub(-10) or word

--     -- sign=sha256(应用ID+input+salt+curtime+应用密钥)；
--     local hash = appid .. input .. salt .. curtime .. appPasswd
--     local sign = vim.fn.sha256(hash)

--     return {
--         q        = word,
--         from     = 'auto',
--         to       = 'zh-CHS',
--         signType = 'v3',
--         appKey   = appid,
--         salt     = salt,
--         curtime  = curtime,
--         sign     = sign,
--     }
-- end

-- return function(word)
--     -- return result
--     -- local field  = get_field(word)
--     -- local output = post(uri, {
--     --     body = field,
--     -- })

--     -- if output.exit == 0 and output.status == 200 then
--     --     local result = vim.fn.json_decode(output.body)
--     --     if result and result.errorCode == 0 then
--     --         --- TODO :
--     --     end
--     -- end
-- end
