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


    require('Trans.backend').baidu.query(data)
    local thread = coroutine.running()
    local resume = function()
        coroutine.resume(thread)
    end

    local time = 0
    while data.result == nil do
        vim.defer_fn(resume, 400)
        time = time + 1
        print('waiting' .. ('.'):rep(time))
        coroutine.yield()
    end
    vim.pretty_print(data)

    M.translate = coroutine.wrap(process)
end

return coroutine.wrap(process)
