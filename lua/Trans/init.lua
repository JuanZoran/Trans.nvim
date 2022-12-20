local M = {}

-- NOTE:
-- Style:
--      [minimal]: one line with '/'
--      [default]:
--      [full]:    show all description in different lines
-- TODO: other style

M.conf = require("Trans.conf")
function M.setup(conf)
    M.conf = vim.tbl_extend('force', M.conf, conf)
    require("Trans.setup")
end

M.db = require("sqlite.db")
M.dict = M.db:open(M.conf.db_path)

return M
