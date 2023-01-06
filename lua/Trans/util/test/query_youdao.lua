local M = {}
-- local type_check = require("Trans.util.debug").type_check
local salt = '96836db9-1e28-4789-b5a6-fb7bb67e1259'
local appKey = '1858465a8708c121'
local appPasswd = 'fG0sitfk16nJOlIlycnLPYZn1optxUxL'

local curtime
local word

local function caculate_input()
    local input
    local len = #word
    if len > 20 then
        input = word:sub(1, 10) .. len .. word:sub(-10)
    else
        input = word
    end
    return input
end

local function caculate_sign()
    -- sign=sha256(应用ID+input+salt+curtime+应用密钥)；
    local hash = appKey .. caculate_input() .. salt .. curtime .. appPasswd

    return vim.fn.sha256(hash)
end

local function test()
    local query = {
        q        = word,
        from     = 'auto',
        to       = 'zh-CHS',
        -- dicts    = 'ec',
        signType = 'v3',
        appKey   = appKey,
        salt     = salt,
        curtime  = curtime,
        sign     = caculate_sign(),
    }
    return query
end

-- curl --data {{'{"name":"bob"}'}} --header {{'Content-Type: application/json'}} {{http://example.com/users/1234}}

local function query_word(q)
    local field = (
        [[curl -s --header 'Content-Type: application/x-www-form-urlencoded' https://openapi.youdao.com/api]])
    for k, v in pairs(q) do
        field = field .. ([[ -d '%s=%s']]):format(k, v)
    end
    -- vim.pretty_print(field)
    local output = vim.fn.system(field)
    local tb = vim.fn.json_decode(output)
    -- print(type(output))
    -- vim.pretty_print(tb.basic)
end

M.test = function(query)
    curtime = tostring(os.time()) -- 更新一下time
    word = query or 'as'
    -- local json = vim.fn.json_encode(test())
    query_word(test())
    -- vim.pretty_print(vim.fn.json_encode(json))
end

return M
