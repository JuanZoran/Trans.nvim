---@class Baidu: TransBackend
---@field uri string api uri
---@field salt string
---@field app_id string
---@field app_passwd string
---@field disable boolean

local M = {
    uri = "https://fanyi-api.baidu.com/api/trans/vip/translate",
    salt = tostring(math.random(bit.lshift(1, 15))),
    name = "baidu",
}

local Trans = require("Trans")

---@class BaiduQuery
---@field q string
---@field from string
---@field to string
---@field appid string
---@field salt string
---@field sign string

---Get content for query
---@param data TransData
---@return BaiduQuery
function M.get_content(data)
    local tmp  = M.app_id .. data.str .. M.salt .. M.app_passwd
    local sign = Trans.util.md5.sumhexa(tmp)

    return {
        q     = data.str,
        from  = data.from,
        to    = data.to,
        appid = M.app_id,
        salt  = M.salt,
        sign  = sign,
    }
end

-- {
--   body = '{"from":"en","to":"zh","trans_result":[{"src":"require","dst":"\\u8981\\u6c42"}]}',
--   exit = 0,
--   headers = { "Content-Type: application/json", "Date: Thu, 09 Mar 2023 14:01:09 GMT", 'P3p: CP=" OTI DSP COR IVA OUR IND COM "', "Server: Apache", "Set-Cookie: BAIDUID=CB6D99CCD3B5F5278B5BE9428F002FC3:FG=1; expires=Fri, 08-Mar-24 14:01:09 GMT; max-age=31536000; path=/; domain=.baidu.com; version=1", "Tracecode: 00696104432377504778030922", "Content-Length: 79", "", "" },
--   status = 200
-- }

---@overload fun(TransData): TransResult
---Query Using Baidu API
---@param data TransData
function M.query(data)
    local handle = function(res)
        local status, body = pcall(vim.json.decode, res.body)
        if not status or not body then
            data.trace        = res
            data.result.baidu = false
            return
        end

        local result = body.trans_result

        if result then
            -- TEST :whether multi result
            assert(#result == 1)
            result = result[1]
            data.result.baidu = {
                ["str"] = result.src,
                [data.from == "en" and "translation" or "definition"] = { result.dst },
            }
        end
    end

    Trans.curl.get(M.uri, {
        query = M.get_content(data),
        callback = handle,
    })
end

---@class TransBackend
---@field baidu Baidu
return M

-- -- NOTE :free tts:
-- -- https://zj.v.api.aa1.cn/api/baidu-01/?msg=我爱你&choose=0&su=100&yd=5
-- -- 选择转音频的人物，女生1 输入0 ｜ 女生2输入：5｜男生1 输入：1｜男生2 输入：2｜男生3 输入：3
