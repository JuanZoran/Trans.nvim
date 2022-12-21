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

M.db = require("sqlite.db")
M.dict = M.db:open(M.conf.db_path)

return M
