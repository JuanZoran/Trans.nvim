local db = require("Trans").db
-- local conf = require("Trans").conf

local group = vim.api.nvim_create_augroup('closedb', { clear = true })
vim.api.nvim_create_autocmd('VimLeave', {
    group = group,
    pattern = '*',
    callback = function()
        if db:isopen() then
            db:close()
        end
    end,
})

vim.api.nvim_create_user_command('TranslateCurosorWord', require("Trans").query_cursor, {})
