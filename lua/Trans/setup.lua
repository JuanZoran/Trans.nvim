local db = require("Trans").db
-- local conf = require("Trans").conf


vim.api.nvim_create_user_command('TranslateCurosorWord', require("Trans.display").query_cursor, {})


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
        { 'InsertEnter', 'CursorMoved', 'BufLeave',  }, {
        group = group,
        pattern = '*',
        callback = require('Trans.display').close_win
    })
end

require("Trans.highlight").set_hl()
