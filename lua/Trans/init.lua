local M = {}

M.conf = require("Trans.conf")
function M.setup(conf)
    conf = conf or {}
    for k, v in pairs(conf) do
        if type(v) == 'table' then
            M.conf[k] = vim.tbl_extend('force', M.conf[k], v)
        else
            M.conf[k] = v
        end
    end
    M.conf = vim.tbl_extend('force', M.conf, conf)
    require("Trans.setup")
end

local res = vim.fn.executable('sqlite3')
if res ~= 1 then
    error('Please check out sqlite3')
end

local status, db = pcall(require, 'sqlite.db')
if not status then
    error('Please check out sqlite.lua')
end

M.db = db

return M
