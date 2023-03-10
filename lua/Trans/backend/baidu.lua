local M = {}


local baidu      = require('Trans').conf.engines.baidu
local app_id     = baidu.app_id
local app_passwd = baidu.app_passwd
local salt       = tostring(math.random(bit.lshift(1, 15)))
local uri        = 'https://fanyi-api.baidu.com/api/trans/vip/translate'

M.get_content    = function(data)
    local tmp  = app_id .. data.str .. salt .. app_passwd
    local sign = require('Trans.util.md5').sumhexa(tmp)
    return {
        q     = data.str,
        from  = data.from,
        to    = data.to,
        appid = app_id,
        salt  = salt,
        sign  = sign,
    }
end

-- {
--   body = '{"from":"en","to":"zh","trans_result":[{"src":"require","dst":"\\u8981\\u6c42"}]}',
--   exit = 0,
--   headers = { "Content-Type: application/json", "Date: Thu, 09 Mar 2023 14:01:09 GMT", 'P3p: CP=" OTI DSP COR IVA OUR IND COM "', "Server: Apache", "Set-Cookie: BAIDUID=CB6D99CCD3B5F5278B5BE9428F002FC3:FG=1; expires=Fri, 08-Mar-24 14:01:09 GMT; max-age=31536000; path=/; domain=.baidu.com; version=1", "Tracecode: 00696104432377504778030922", "Content-Length: 79", "", "" },
--   status = 200
-- }


M.query = function(data)
    data.engine = 'baidu'

    local handle = function(res)
        local status, body = pcall(vim.json.decode, res.body)
        if status and body then
            local result = body.trans_result
            if result then
                -- TEST :whether multi result
                assert(#result == 1, 'multi result :' .. vim.inspect(result))
                result = result[1]
                data.result = {
                    title = result.src,
                    translation = result.dst,
                }
                return
            end
        end

        data.result = false
        data.trace = res
    end

    require('Trans.wrapper.curl').get(uri, {
        query = M.get_content(data),
        callback = handle,
    })
end

return M

-- -- NOTE :free tts:
-- -- https://zj.v.api.aa1.cn/api/baidu-01/?msg=我爱你&choose=0&su=100&yd=5
-- -- 选择转音频的人物，女生1 输入0 ｜ 女生2输入：5｜男生1 输入：1｜男生2 输入：2｜男生3 输入：3
