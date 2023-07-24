---@class Trans
local Trans = require 'Trans'

---@alias TransMode 'visual' 'input'
local default_strategy = {
    frontend = 'hover',
    backend  = {
        'offline',
        -- 'youdao',
        -- 'baidu',
    },
}

Trans.conf = {
    ---@type string the directory for database file and password file
    dir      = require 'Trans'.plugin_dir,
    ---@type 'default' | 'dracula' | 'tokyonight' global Trans theme [@see lua/Trans/style/theme.lua]
    theme    = 'default',
    ---@type table<TransMode, { frontend:string, backend:string | string[] }> fallback strategy for mode
    -- input = {
    -- visual = {
    -- ...
    strategy = vim.defaulttable(function()
        return setmetatable({}, default_strategy)
    end),
    frontend = {},
}



---@class Trans
---@field setup fun(opts: { mode: string, mode: string })
return function(opts)
    if opts then
        Trans.conf = vim.tbl_deep_extend('force', Trans.conf, opts)
    end
    local conf = Trans.conf
    conf.dir   = vim.fn.expand(conf.dir)

    -- INFO : set highlight
    local set_hl     = vim.api.nvim_set_hl
    local highlights = Trans.style.theme[conf.theme]
    for hl, opt in pairs(highlights) do
        set_hl(0, hl, opt)
    end
end
