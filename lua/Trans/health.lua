local check = function()
    local health = vim.health
    local ok     = health.report_ok
    local warn   = health.report_warn
    local error  = health.report_error

    local has        = vim.fn.has
    local executable = vim.fn.executable

    -- INFO :Check neovim version
    if has('nvim-0.9') == 1 then
        ok [[You have [neovim-nightly] ]]
    else
        warn [[Trans Title requires Neovim 0.9 or newer
        See neovim-nightly: [https://github.com/neovim/neovim/releases/tag/nightly]
        ]]
    end

    -- INFO :Check plugin dependencies
    local plugin_dependencies = {
        'plenary',
        'sqlite',
    }

    for _, dep in ipairs(plugin_dependencies) do
        if pcall(require, dep) then
            ok(string.format('Dependency [%s] is installed', dep))
        else
            error(string.format('Dependency [%s] is not installed', dep))
        end
    end

    -- INFO :Check binary dependencies
    local binary_dependencies = {
        'curl',
        'sqlite3',
    }

    if has('linux') == 1 then
        binary_dependencies[3] = 'festival'
    elseif has('mac') == 1 then
        binary_dependencies[3] = 'say'
    else
        binary_dependencies[3] = 'node'
    end

    for _, dep in ipairs(binary_dependencies) do
        if executable(dep) == 1 then
            ok(string.format('Binary dependency [%s] is installed', dep))
        else
            error(string.format('Binary dependency [%s] is not installed', dep))
        end
    end


    -- INFO :Check ultimate.db
    local db_path = vim.fn.expand(require('Trans').conf.dir .. '/ultimate.db')
    if vim.fn.filereadable(db_path) == 1 then
        ok [[ultimate database found ]]
    else
        error [[Stardict database not found
        Please check the doc in github: [https://github.com/JuanZoran/Trans.nvim]
        ]]
    end


    -- INFO :Check Engine configuration file
    local path = vim.fn.expand(require('Trans').conf.dir .. '/Trans.json')
    local file = io.open(path, "r")
    local valid = file and pcall(vim.json.decode, file:read("*a"))
    if valid then
        ok [[Engine configuration file found and valid ]]
    else
        error [[Engine configuration file not found or invalid
        Please check the doc in github: [https://github.com/JuanZoran/Trans.nvim]
        ]]
    end
end

return { check = check }
