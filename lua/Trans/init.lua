local M = {}


M.conf = require("Trans.conf")
function M.setup(conf)
    if conf.display then
        conf.display = vim.tbl_extend('force', M.conf.display, conf.display)
    end

    if conf.icon then
        conf.icon = vim.tbl_extend('force', M.conf.icon, conf.icon)
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
