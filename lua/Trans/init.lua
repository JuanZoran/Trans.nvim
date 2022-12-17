M = {}

local default_config = {
    display = {
        style = '',
        phnoetic = true,
        collins_star = true,
        tag = true,
        oxford = true,
    },
    default_cmd = true,
}

M.config = default_config

function M.setup(conf)
    M.config = vim.tbl_extend('force', default_config, conf)
end

return M
