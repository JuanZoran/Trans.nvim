local baidu     = require('Trans').conf.engine.baidu
local appid     = baidu.appid
local appPasswd = baidu.appPasswd
local salt      = tostring(math.random(bit.lshift(1, 15)))
local uri       = 'https://fanyi-api.baidu.com/api/trans/vip/translate'

if appid == '' or appPasswd == '' then
    error('请查看README, 实现在线翻译或者设置将在线翻译设置为false')
end

local post = require('Trans.util.curl').POST

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

--- this is a nice plugin
---返回一个channel
---@param word string
---@return function
return function(word)
    local query = get_field(word)
    local result

    post(uri, {
        data = query,
        headers = {
            content_type = "application/x-www-form-urlencoded",
        },
        callback = function(str)
            if result then
                return
            elseif str ~= '' then
                local res = vim.fn.json_decode(str)
                if res and res.trans_result then
                    result = {
                        word = word,
                        translation = res.trans_result[1].dst,
                    }

                else
                    result = false
                end
            else
                result = false
            end
        end,
    })

    return function()
        return result
    end
end
