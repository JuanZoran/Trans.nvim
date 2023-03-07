local M = {}

M.check = function()
    local health = vim.health
    local ok     = health.report_ok
    local warn   = health.report_warn
    local error  = health.report_error


    local has        = vim.fn.has
    local executable = vim.fn.executable

    -- INFO :Check neovim version
    if has('nvim-0.9') == 1 then
        ok [[
        [PASS]: you have Trans.nvim with full features in neovim-nightly
        ]]
    else
        warn [[
        [WARN]: Trans Title requires Neovim 0.9 or newer
        See neovim-nightly: https://github.com/neovim/neovim/releases/tag/nightly
        ]]
    end

    -- INFO :Check Sqlite
    local has_sqlite = pcall(require, 'sqlite')
    if has_sqlite then
        ok [[
        [PASS]: Dependency sqlite.lua is installed
        ]]
    else
        error [[
        [ERROR]: Dependency sqlite.lua can't work correctly
        Please Read the doc in github carefully
        ]]
    end

    if executable('sqlite3') then
        ok [[
        [PASS]: Dependency sqlite3 found
        ]]
    else
        error [[
        [ERROR]: Dependency sqlite3 not found
        ]]
    end


    -- INFO :Check stardict
    local db_path = vim.fn.expand(require('Trans').conf.db_path)
    if vim.fn.filereadable(db_path) == 1 then
        ok [[
        [PASS]: Stardict database found
        ]]
    else
        error [[
        [PASS]: Stardict database not found
        Please check the doc in github
        ]]
    end
end

return M
