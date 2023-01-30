local youdao    = require("Trans").conf.engine.youdao
local appKey    = youdao.appKey
local appPasswd = youdao.appPasswd
local uri       = 'https://openapi.youdao.com/api'
local salt      = tostring(math.random(bit.rshift(1, 5)))


local ok, curl = pcall(require, 'plenary.curl')
if not ok then
    error('plenary not found')
end


local function get_field(word)
    local len     = #word
    local curtime = tostring(os.time())
    local input   = len > 20 and
        word:sub(1, 10) .. len .. word:sub(-10) or word

    -- sign=sha256(应用ID+input+salt+curtime+应用密钥)；
    local hash = appKey .. input .. salt .. curtime .. appPasswd
    local sign = vim.fn.sha256(hash)

    return {
        q        = word,
        from     = 'auto',
        to       = 'zh-CHS',
        signType = 'v3',
        appKey   = appKey,
        salt     = salt,
        curtime  = curtime,
        sign     = sign,
    }
end

return function(word)
    -- return result
    local field  = get_field(word)
    local output = curl.post(uri, {
        body = field,
    })
    if output.exit == 0 and output.status == 200 then
        local result = vim.fn.json_decode(output.body)
        if result and result.errorCode == 0 then
            --- TODO :
        end
    end
end
