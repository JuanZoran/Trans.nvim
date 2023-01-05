local M = {}

M.conf = {}

function M.setup(conf)
    M.conf = conf or {}
    if conf.base and not conf.base.lazy_load then
        require("Trans.conf.loader").load_conf()
    end
    require("Trans.setup")
end

return M
