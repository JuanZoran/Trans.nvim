if vim.fn.executable('sqlite3') ~= 1 then
    error('Please check out sqlite3')
end

vim.api.nvim_create_user_command('Translate', function()
    require("Trans").translate()
end, {
    desc = '  单词翻译',
})

vim.api.nvim_create_user_command('TranslateInput', function()
    require("Trans").translate('input')
end, { desc = '  搜索翻译' })


local highlights = {
    TransWord = {
        fg = '#7ee787',
        bold = true,
    },
    TransPhonetic = {
        link = 'Linenr'
    },
    TransTitle = {
        fg = '#0f0f15',
        bg = '#75beff',
        bold = true,
    },
    TransTitleRound = {
        fg = '#75beff',
    },
    TransTag = {
        fg = '#e5c07b',
    },
    TransExchange = {
        link = 'TransTag',
    },
    TransPos = {
        link = 'TransTag',
    },
    TransTranslation = {
        link = 'TransWord',
    },
    TransDefinition = {
        link = 'Moremsg',
    },
    TransHoverWin = {
        link = 'Normal',
    },
    TransHoverBorder = {
        link = 'FloatBorder',
    },
    TransCollins = {
        fg = '#faf743',
        bold = true,
    },
    TransNotFound = {
        fg = '#7aa89f',
    },
}

-- TODO
-- vim.api.nvim_create_user_command('TranslateHistory', require("Trans.core").query_input, {
--     desc = '翻译输入的单词',
-- })

for highlight, opt in pairs(highlights) do
    vim.api.nvim_set_hl(0, highlight, opt)
end
