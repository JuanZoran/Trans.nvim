local Trans = require('Trans')
local M = Trans.metatable('frontend')


-- local default_opts = vim.deepcopy(Trans.conf.frontend)
-- for name, private_opts in pairs(result or {}) do
--     local opts = vim.tbl_extend('keep', Trans.conf.backend[name] or {}, default_opts, private_opts)

--     local backend = M[name]
--     for k, v in pairs(opts) do
--         if not backend[k] then
--             backend[k] = v
--         end
--     end
-- end

return M
