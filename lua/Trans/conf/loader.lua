---@diagnostic disable: unused-local, unused-function
local M = {}

local replace_rules = require("Trans.conf.default").replace_rules
local conf          = require("Trans.conf.default").conf
local user_conf     = require("Trans").conf
local type_check    = require("Trans.util.debug").type_check
local is_loaded = false

local function need_extend(name)
    type_check {
        name = { name, 'string' }
    }
    for _, rule in ipairs(replace_rules) do
        if name:match(rule) then
            return false
        end
    end
    return true
end

-- 加载用户自定义的配置
---@param t1 table
---@param t2 table
local function extend(t1, t2)
    type_check {
        t1 = { t1, 'table' },
        t2 = { t2, 'table' },
    }
    for k, v in pairs(t2) do
        if type(v) == 'table' and need_extend(k) then
            extend(t1[k], v)
        else
            t1[k] = v
        end
    end
end

M.get_conf = function()
    if not is_loaded then
        M.load_conf()
    end
    return conf
end

M.load_conf = function()
    -- loaded_conf = default_conf:extend(user_conf)
    extend(conf, user_conf)
    is_loaded = true
end

return M
