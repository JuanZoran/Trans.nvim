local Trans = require('Trans')
local M = Trans.metatable('backend')

--- INFO :Parse online engine keys config file
local path = Trans.conf.dir .. '/Trans.json'
local file = io.open(path, "r")

if file then
    local content = file:read("*a")
    local status, result = pcall(vim.json.decode, content)
    file:close()
    if not status then
        error('Unable to parse json file: ' .. path .. '\n' .. result)
    end



    local default_opts = vim.deepcopy(Trans.conf.backend)
    for name, private_opts in pairs(result or {}) do
        local opts = vim.tbl_extend('keep', Trans.conf.backend[name] or {}, default_opts, private_opts)

        local backend = M[name]
        for k, v in pairs(opts) do
            if not backend[k] then
                backend[k] = v
            end
        end
    end
end


return M
