local _, db = pcall(require, 'sqlite.db')
if not _ then
    error('Please check out sqlite.lua')
end

-- INFO : init database
local path = require('Trans').conf.db_path
local dict = db:open(path)

vim.api.nvim_create_autocmd('VimLeavePre', {
    group = require("Trans").augroup,
    callback = function()
        if db:isopen() then
            db:close()
        end
    end
})

return function(word)
    local res = dict:select('stardict', {
        where = {
            word = word,
        },
        keys = {
            'word',
            'phonetic',
            'definition',
            'translation',
            'pos',
            'collins',
            'oxford',
            'tag',
            'exchange',
        },
        limit = 1,
    })
    return res[1]
end