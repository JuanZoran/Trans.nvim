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

local field = {
    "phonetic",
    'usPhonetic',
    "ukPhonetic",
    "text",           --	text	短语
    "explain",        --	String Array	词义解释列表
    "wordFormats",    --	Object Array	单词形式变化列表
    "name",           --	String	形式名称，例如：复数
    "phrase",         --	String	词组
    "meaning",        --	String	含义
    "synonyms",       --	JSONObject	近义词
    "pos",            --	String	词性
    "words",          --	String Array	近义词列表
    "trans",          --	String	释义
    "antonyms",       --	ObjectArray	反义词
    "relatedWords",   --	JSONArray	相关词
    "wordNet",        --	JSONObject	汉语词典网络释义
    "phonetic",       --	String	发音
    "meanings",       --	ObjectArray	释义
    "meaning",        --	String	释义
    "example",        --	array	示例
    "sentenceSample", --	text	例句
    "sentence",       --	text	例句
    "sentenceBold",   --	text	将查询内容加粗的例句
    "wfs",            --	text	单词形式变化
    "exam_type",      --	text	考试类型
}


---@overload fun(TransData): TransResult
---Query Using Youdao API
---@param data TransData
function M.query(data)
    local handle = function(res)
        local status, body = pcall(vim.json.decode, res.body)
        -- vim.print(body)
        if body then
            for _, f in ipairs(field) do
                if body[f] then
                    print(('%s found : %s'):format(f, vim.inspect(body[f])))
                end
            end
        end

        if not status or not body or body.errorCode ~= "0" then
            data.result.youdao = false
            data[#data + 1] = res
            return
        end

        if not body.isWord then
            data.result.youdao = {
                title = body.query,
                [data.from == 'en' and 'translation' or 'definition'] = body.translation,
            }
            return
        end


        local tmp = {
            title                                                 = {
                word     = body.query,
                phonetic = body.basic.phonetic,
            },
            web                                                   = body.web,
            phrases                                               = body.phrases,
            explains                                              = body.basic.explains,
            synonyms                                              = body.synonyms,
            sentenceSample                                        = body.sentenceSample,
            [data.from == 'en' and 'translation' or 'definition'] = body.translation,
        }


        data.result.youdao = tmp
    end

    require('Trans').curl.get(M.uri, {
        query = M.get_content(data),
        callback = handle,
    })
end

---@class TransBackend
---@field youdao Youdao
return M

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
