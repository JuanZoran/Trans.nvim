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

        local result = body.trans_result
        if result then
            -- TEST :whether multi result
            assert(#result == 1)
            result = result[1]
            data.result.youdao = {
                ['title'] = result.src,
                [data.from == 'en' and 'translation' or 'definition'] = { result.dst },
            }
        end
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
