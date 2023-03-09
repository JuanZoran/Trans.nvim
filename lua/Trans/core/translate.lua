local M = require('Trans')
local util = M.util


local process
process = function(opts)
    opts = opts or {}
    local mode = opts.mode or vim.api.nvim_get_mode().mode
    local str = util.get_str(mode)
    if str == '' then return end

    local data = {
        str = str,
        view = opts.view or M.conf.view[mode],
        mode = mode,
    }

    if util.is_English(str) then
        data.from = 'en'
        data.to = 'zh'
    else
        data.from = 'zh'
        data.to = 'en'
    end


    local res = require('Trans.backend').offline.query(data)
    -- vim.pretty_print(res)

    M.translate = coroutine.wrap(process)
end

return process
