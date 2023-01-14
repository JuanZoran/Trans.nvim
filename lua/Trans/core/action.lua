local function feedkey(mode, key)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), mode, false)
end

local util = require('Trans.util')

local M = {
    pageup = function(bufnr, winid)
        local top = math.min(10, util.get_height(bufnr, winid) - vim.api.nvim_win_get_height(winid) + 1)
        return function()
            vim.api.nvim_buf_call(bufnr, function()
                -- TODO :
                vim.cmd([[normal!]] .. top .. 'zt')
                -- vim.cmd([[normal!]] .. 'G')
                -- vim.api.nvim_command("noautocmd silent! normal! " .. vim.wo.scroll .. "zt")
                -- vim.cmd([[do WinScrolled]])
            end)
        end
    end,
    pagedown = function()
        feedkey('n', '<C-d>')
    end
}


return M
