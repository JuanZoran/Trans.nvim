-- -@diagnostic disable: unused-local, unused-function, lowercase-global
local M = {}

local replace_rules = require("Trans.conf.default").replace_rules

local star_format = [[
local def, usr = default_conf.%s, user_conf.%s
if def and usr then
    for k, v in pairs(usr) do
        def[k] = v
        usr[k] = nil
    end
end
]]


local plain_format = [[
default_conf.%s = user_conf.%s or default_conf.%s
]]

local function pre_process()
    if replace_rules then
        for _, v in ipairs(replace_rules) do
            local start = v:find('.*', 1, true)
            local operation
            if start then
                -- 替换表内所有键
                v = v:sub(1, start - 1)
                -- print('v is :', v)
                operation = string.format(star_format, v, v)
            else
                operation = plain_format:format(v, v, v)
            end
            -- print(operation)
            pcall(loadstring(operation))
        end
    end
end

M.load_conf = function(conf)
    user_conf    = conf or {}
    default_conf = require("Trans.conf.default").conf
    if user_conf.style and user_conf.window then
    end

    pre_process()
    M.loaded_conf = vim.tbl_deep_extend('force', default_conf, user_conf)
    local width = M.loaded_conf.style.window.float.width
    local height = M.loaded_conf.style.window.float.height

    if width > 0 and width <= 1 then
        M.loaded_conf.style.window.float.width = math.floor(width * vim.o.columns)
    end

    if height > 0 and height <= 1 then
        M.loaded_conf.style.window.float.height = math.floor(height * (vim.o.lines - vim.o.cmdheight))
    end

    user_conf = nil
    default_conf = nil
end

M.loaded_conf = nil

return M
