local db = require("Trans").db
-- local conf = require("Trans").conf


vim.api.nvim_create_user_command('TranslateCursorWord', require("Trans.display").query_cursor, {})
vim.api.nvim_create_user_command('TranslateSelectWord', require("Trans.display").query_select, {})


local group = vim.api.nvim_create_augroup("Trans", { clear = true })
vim.api.nvim_create_autocmd('VimLeave', {
    group = group,
    pattern = '*',
    callback = function()
        if db:isopen() then
            db:close()
        end
    end,
})

-- TODO: set command to close preview window automatically
local auto_close = require("Trans.conf").auto_close
if auto_close then
    vim.api.nvim_create_autocmd(
        { 'InsertEnter', 'CursorMoved', 'BufLeave', }, {
        group = group,
        pattern = '*',
        callback = require('Trans.display').close_win
    })
end


-- vim.keymap.set('n', 'mm', '<cmd>TranslateCurosorWord<cr>')
-- vim.keymap.set('v', 'mm', '<Esc><cmd>TranslateSelectWord<cr>')
require("Trans.highlight").set_hl()
