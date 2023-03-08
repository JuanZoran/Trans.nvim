local baidu     = require('Trans').conf.engine.baidu
local appid     = baidu.appid
local appPasswd = baidu.appPasswd
local salt      = tostring(math.random(bit.lshift(1, 15)))
local uri       = 'https://fanyi-api.baidu.com/api/trans/vip/translate'

-- error('请查看README, 实现在线翻译或者设置将在线翻译设置为false')

local post      = require('Trans.util.curl').POST

local function get_field(word, isEn)
    local to   = isEn and 'zh' or 'en'
    local tmp  = appid .. word .. salt .. appPasswd
    local sign = require('Trans.util.md5').sumhexa(tmp)

    return {
        q     = word,
        from  = 'auto',
        to    = to,
        appid = appid,
        salt  = salt,
        sign  = sign,
    }
end

---返回一个channel
---@param word string
---@return table
return function(word)
    local isEn = word:isEn()
    local query = get_field(word, isEn)
    local result = {}

    post(uri, {
        data = query,
        headers = {
            content_type = "application/x-www-form-urlencoded",
        },
        callback = function(str)
            local ok, res = pcall(vim.json.decode, str)
            if ok and res and res.trans_result then
                result[1] = {
                    title = { word = word },
                        [isEn and 'translation' or 'definition'] = res.trans_result[1].dst,
                }

                if result.callback then
                    result.callback(result[1])
                end
            else
                result[1] = false
            end
        end,
    })

    return result
end



-- NOTE :free tts:
-- https://zj.v.api.aa1.cn/api/baidu-01/?msg=我爱你&choose=0&su=100&yd=5
-- 选择转音频的人物，女生1 输入0 ｜ 女生2输入：5｜男生1 输入：1｜男生2 输入：2｜男生3 输入：3
