local type_check = require("Trans.util.debug").type_check
local format = require("Trans.util.format")


-- NOTE : 将请求得到的字段进行处理
-- local offline_dir = debug.getinfo(1, "S").source:sub(2):match('.*Trans') .. '/component/offline'
local function process (opts)
    type_check {
        opts = { opts, 'table' }
    }
    local content = require('Trans.component.content'):new()

    for _, v in ipairs(opts.order) do
        local component = format.format(opts.win_style, require("Trans.component" .. opts.engine .. v))
        content:insert(component)
    end

    return content:lines()
end


return process
