-- local util = require('Trans.util')
local bufnr = require('Trans.core.window').bufnr
-- local winid = require('Trans.core.window').id
local api = vim.api
local function buf_feedkey(key)
    if bufnr and api.nvim_buf_is_valid(bufnr) then
        api.nvim_buf_call(bufnr, function()
            vim.cmd([[normal! ]] .. key)
        end)
        return true
    else
        return false
    end
end

local M = {
    pageup = function()
        return buf_feedkey('gg')
    end,
    pagedown = function()
        return buf_feedkey('G')
    end
}

return M
