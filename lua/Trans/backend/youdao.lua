---@class Youdao: TransOnlineBackend
---@field uri string api uri
---@field salt string
---@field app_id string
---@field app_passwd string
---@field disable boolean
local M = {
    uri     = 'https://openapi.youdao.com/api',
    salt    = tostring(math.random(bit.lshift(1, 15))),
    name    = 'youdao',
    name_zh = '有道',
    method  = 'get',
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
function M.get_query(data)
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

local function check_untracked_field(body)
    local field = {
        'phonetic',
        'usPhonetic',
        'ukPhonetic',
        'text',           --	text	短语
        'explain',        --	String Array	词义解释列表
        'wordFormats',    --	Object Array	单词形式变化列表
        'name',           --	String	形式名称，例如：复数
        'phrase',         --	String	词组
        'meaning',        --	String	含义
        'synonyms',       --	JSONObject	近义词
        'pos',            --	String	词性
        'words',          --	String Array	近义词列表
        'trans',          --	String	释义
        'antonyms',       --	ObjectArray	反义词
        'relatedWords',   --	JSONArray	相关词
        'wordNet',        --	JSONObject	汉语词典网络释义
        'phonetic',       --	String	发音
        'meanings',       --	ObjectArray	释义
        'meaning',        --	String	释义
        'example',        --	array	示例
        'sentenceSample', --	text	例句
        'sentence',       --	text	例句
        'sentenceBold',   --	text	将查询内容加粗的例句
        'wfs',            --	text	单词形式变化
        'exam_type',      --	text	考试类型
    }
    for _, f in ipairs(field) do
        if body[f] then
            print(('%s found : %s'):format(f, vim.inspect(body[f])))
        end
    end
end




function M.debug(body)
    if not body then
        vim.notify('Unknown errors, nil body', vim.log.levels.ERROR)
    end
    local debug_msg = ({
        [101] = '缺少必填的参数,首先确保必填参数齐全，然后确认参数书写是否正确。',
        [102] = '不支持的语言类型',
        [103] = '翻译文本过长',
        [104] = '不支持的API类型',
        [105] = '不支持的签名类型',
        [106] = '不支持的响应类型',
        [107] = '不支持的传输加密类型',
        [108] = '应用ID无效，注册账号，登录后台创建应用和实例并完成绑定，可获得应用ID和应用密钥等信息',
        [109] = 'batchLog格式不正确',
        [110] = '无相关服务的有效实例,应用没有绑定服务实例，可以新建服务实例，绑定服务实例。注：某些服务的翻译结果发音需要tts实例，需要在控制台创建语音合成实例绑定应用后方能使用。',
        [111] = '开发者账号无效',
        [113] = 'q不能为空',
        [120] = '不是词，或未收录',
        [201] = '解密失败，可能为DES,BASE64,URLDecode的错误',
        [202] = '签名检验失败',
        [203] = '访问IP地址不在可访问IP列表',
        [205] = '请求的接口与应用的平台类型不一致，确保接入方式（Android SDK、IOS SDK、API）与创建的应用平台类型一致。如有疑问请参考入门指南',
        [206] = '因为时间戳无效导致签名校验失败',
        [207] = '重放请求',
        [301] = '辞典查询失败',
        [302] = '翻译查询失败',
        [303] = '服务端的其它异常',
        [305] = '批量翻译部分成功',
        [401] = '账户已经欠费，请进行账户充值',
        [411] = '访问频率受限,请稍后访问',
        [412] = '长请求过于频繁，请稍后访问',
        [390001] = '词典名称不正确',
    })[tonumber(body.errorCode)]

    vim.notify('Youdao API Error: ' .. (debug_msg or vim.inspect(body)), vim.log.levels.ERROR)
end

---@overload fun(TransData): TransResult
---Query Using Youdao API
---@param body table Youdao ouput
---@param data TransData Data obj
---@return table|false?
function M.formatter(body, data)
    if body.errorCode ~= '0' then return false end
    check_untracked_field(body)

    if not body.isWord then
        return {
            title = body.query,
            [data.from == 'en' and 'translation' or 'definition'] = body.translation,
        }
    end


    return {
        title                                                 = {
            word     = body.query,
            phonetic = body.basic.phonetic,
        },
        web                                                   = body.web,
        explains                                              = body.basic.explains,
        [data.from == 'en' and 'translation' or 'definition'] = body.translation,
    }
end

---@class TransBackend
---@field youdao Youdao
return M

-- INFO :Query Result Example
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
