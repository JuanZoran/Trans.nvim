
local function feedkey(mode, key)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), mode, false)
end


local M = {
    pageup = function (bufnr)
        return function ()
            vim.api.nvim_buf_call(bufnr, function ()
                -- TODO :
            end)
        end
    end,
    pagedown = function ()
        feedkey('n', '<C-d>')
    end
}


return M
