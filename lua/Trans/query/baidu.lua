local baidu     = require('Trans').conf.engine.baidu
local appid     = baidu.appid
local appPasswd = baidu.appPasswd
local salt      = tostring(math.random(bit.rshift(1, 5)))
local uri       = 'https://fanyi-api.baidu.com/api/trans/vip/translate'

if appid == '' or appPasswd == '' then
    error('请查看README, 实现在线翻译或者设置将在线翻译设置为false')
end

local ok, curl = pcall(require, 'plenary.curl')
if not ok then
    error('plenary not found')
end

local function get_field(word)
    local to   = 'zh'
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

return function(word)
    local query = get_field(word)
    local output = curl.post(uri, {
        data = query,
        headers = {
            content_type = "application/x-www-form-urlencoded",
        }
    })

    if output.exit == 0 and output.status == 200 then
        local res = vim.fn.json_decode(output.body)
        if res and res.trans_result then
            return {
                word = word,
                translation = res.trans_result[1].dst,
            }
        end
    end
end
