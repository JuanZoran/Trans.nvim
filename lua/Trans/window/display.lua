local M = {}
local api = vim.api
local util = require("Trans.window.util")
M.buf = util.init_buf()

--- 浮动窗口的风格
---@param conf table 自定义配置
M.show_float_win = function(conf)
    vim.validate {
        conf = { conf, 'table' },
    }
    local opts = util.get_float_opts(conf)
    local win = api.nvim_open_win(M.buf, true, opts)
    return win
end

M.show_cursor_win = function(conf)
    vim.validate {
        conf = { conf, 'table' },
    }
    local opts = util.get_cursor_opts(conf)
    local win = api.nvim_open_win(M.buf, true, opts)
    return win
end

-- TODO <++> more window style


return M
