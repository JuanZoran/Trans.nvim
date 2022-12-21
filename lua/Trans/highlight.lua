local M = {}

M.hlgroup = {
    word     = 'TransWord',
    phonetic = 'TransPhonetic',
    ref      = 'TransRef',
    tag      = 'TransTag',
    exchange = 'TransExchange',
    pos      = 'TransPos',
    zh       = 'TransZh',
    en       = 'TransEn',
}

function M.set_hl()
    -- FIXME: highlight doesn't work
    local set_hl = vim.api.nvim_set_hl
    set_hl(0, M.hlgroup.word, { fg = '#98c379', bold = true })
    set_hl(0, M.hlgroup.phonetic, { fg = '#8b949e' })
    set_hl(0, M.hlgroup.ref, { fg = '#75beff', bold = true })
    set_hl(0, M.hlgroup.tag, { fg = '#e5c07b' })
    set_hl(0, M.hlgroup.pos, { link = M.hlgroup.tag })
    set_hl(0, M.hlgroup.exchange, { link = M.hlgroup.tag })
    set_hl(0, M.hlgroup.zh, { fg = '#7ee787' })
    set_hl(0, M.hlgroup.en, { fg = '#bc8cff' })
end

return M
