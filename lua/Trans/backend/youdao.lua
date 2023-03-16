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


    local chars = vim.str_utf_pos(str)
    local count = #chars
    local input = count <= 20 and str or
        str:sub(1, chars[11] - 1) .. #chars .. str:sub(chars[count - 9])


    -- sign=sha256(应用ID+input+salt+curtime+应用密钥)； 一二三四五六七八九十
    local hash = app_id .. input .. salt .. curtime .. M.app_passwd
    local sign = vim.fn.sha256(hash)


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

-- {
--   basic = {
--     explains = { "normal profit" }
--   },
--   dict = {
--     url = "yddict://m.youdao.com/dict?le=eng&q=%E6%AD%A3%E5%B8%B8%E5%88%A9%E6%B6%A6"
--   },
--   errorCode = "0",
--   isWord = true,
--   l = "zh-CHS2en",
--   mTerminalDict = {
--     url = "https://m.youdao.com/m/result?lang=zh-CHS&word=%E6%AD%A3%E5%B8%B8%E5%88%A9%E6%B6%A6"
--   },
--   query = "正常利润",
--   requestId = "87a0b1bf-a5a2-46d1-8604-cd765cd06a90",
--   returnPhrase = { "正常利润" },
--   speakUrl = "https://openapi.youdao.com/ttsapi?q=%E6%AD%A3%E5%B8%B8%E5%88%A9%E6%B6%A6&langType=zh-CHS&sign=5DC3A57D7D4CB21892D0D77E6968F03D&salt=1678950274137&voice=4&format=mp3&appKey=1858465a8708c121&ttsVoiceStrict=false",
--   tSpeakUrl = "https://openapi.youdao.com/ttsapi?q=Normal+profit&langType=en-USA&sign=325FA5994D5D3B859DF21E3522577AFB&salt=1678950274137&voice=4&format=mp3&appKey=1858465a8708c121&ttsVoiceStrict=false",
--   translation = { "Normal profit" },
--   web = { {
--       key = "正常利润",
--       value = { "normal profits" }
--     }, {
--       key = "非正常利润",
--       value = { "abnormal profits" }
--     }, {
--       key = "正常利润率",
--       value = { "normal profit rate" }
--     } },
--   webdict = {
--     url = "http://mobile.youdao.com/dict?le=eng&q=%E6%AD%A3%E5%B8%B8%E5%88%A9%E6%B6%A6"
--   }
-- }



---@overload fun(TransData): TransResult
---Query Using Youdao API
---@param data TransData
function M.query(data)
    local handle = function(res)
        local status, body = pcall(vim.json.decode, res.body)
        vim.print(body)
        if not status or not body or body.errorCode ~= "0" then
            data.result.youdao = false
            data[#data + 1] = res
            return
        end

        if not body.isWord then
            data.result.youdao = {
                str = body.query,
                [data.from == 'en' and 'translation' or 'definition'] = body.translation,
            }
            return
        end

        if true then
            data.result.youdao = false
            return
        end

        data.result.youdao = {
            title                                                 = {
                phonetic = body.basic.phonetic,
            },
            web                                                   = body.web,
            phrases                                               = body.phrases,
            explains                                              = body.basic.explains,
            synonyms                                              = body.synonyms,
            translation                                           = body.translation,
            sentenceSample                                        = body.sentenceSample,
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
