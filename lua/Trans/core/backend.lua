local Trans = require('Trans')
local M = Trans.metatable('backend')
local conf = Trans.conf

--- INFO :Parse online engine keys config file
local path = conf.dir .. '/Trans.json'
local file = io.open(path, "r")

if file then
    local content = file:read("*a")
    local status, result = pcall(vim.json.decode, content)
    file:close()
    if not status then
        error('Unable to parse json file: ' .. path .. '\n' .. result)
    end


    for name, private_opts in pairs(result or {}) do
        local opts = vim.tbl_extend('keep', conf.backend[name] or {}, conf.backend.default, private_opts)
        for k, v in pairs(opts) do
            M[name][k] = v
        end
    end
end

return M
