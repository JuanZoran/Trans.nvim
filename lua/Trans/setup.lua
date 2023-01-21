if vim.fn.executable('sqlite3') ~= 1 then
    error('Please check out sqlite3')
end


vim.api.nvim_create_user_command('Translate', function()
    require("Trans").translate()
end, { desc = '  单词翻译', })

vim.api.nvim_create_user_command('TranslateInput', function()
    require("Trans").translate('i')
end, { desc = '  搜索翻译' })

-- vim.api.nvim_create_user_command('TranslateLast', function()
--     require("Trans").translate('last')
-- end, { desc = '  显示上一次查询的内容' })

local hls = {
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
    TransWin = {
        link = 'Normal',
    },
    TransBorder = {
        link = 'FloatBorder',
    },
    TransCollins = {
        fg = '#faf743',
        bold = true,
    },
    TransFailed = {
        fg = '#7aa89f',
    },
}

for hl, opt in pairs(hls) do
    vim.api.nvim_set_hl(0, hl, opt)
end
