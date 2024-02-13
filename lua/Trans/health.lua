local Trans      = require 'Trans'
local health, fn = vim.health, vim.fn

local ok         = health.report_ok
local warn       = health.report_warn
local error      = health.report_error
local has        = fn.has
local executable = fn.executable

local function check_neovim_version()
    if has 'nvim-0.9' == 1 then
        ok [[You have [neovim-nightly] ]]
    else
        warn [[Trans Title requires Neovim 0.9 or newer
        See neovim-nightly: [https://github.com/neovim/neovim/releases/tag/nightly]
        ]]
    end
end

local function check_plugin_dependencies()
    local plugin_dependencies = {
        -- 'plenary',
        'sqlite',
    }

    for _, dep in ipairs(plugin_dependencies) do
        if pcall(require, dep) then
            ok(string.format('Dependency [%s] is installed', dep))
        else
            error(string.format('Dependency [%s] is not installed', dep))
        end
    end
end

local function check_binary_dependencies()
    local binary_dependencies = {
        'curl',
        'sqlite3',
        'unzip',
    }

    binary_dependencies[3] = ({
        win    = nil,
        mac    = 'say',
        linux  = 'festival',
        termux = 'termux-tts-speak',
    })[Trans.system]


    for _, dep in ipairs(binary_dependencies) do
        if executable(dep) == 1 then
            ok(string.format('Binary dependency [%s] is installed', dep))
        else
            error(string.format('Binary dependency [%s] is not installed', dep))
        end
    end
end

local function check_database()
    local db_path = Trans.conf.dir .. '/ultimate.db'
    if fn.filereadable(db_path) == 1 then
        ok [[ultimate database found ]]
    else
        error [[Stardict database not found
        [Manually]: Please check the doc in github: [https://github.com/JuanZoran/Trans.nvim]
        [Automatically]: Try to run `:lua require "Trans".install()`
        ]]
    end
end

local function check_configure_file()
    local path = fn.expand(Trans.conf.dir .. '/Trans.json')
    if not fn.filereadable(path) then
        warn 'Backend configuration file[%s] not found'
    end

    local file = io.open(path, 'r')
    local valid = file and pcall(vim.json.decode, file:read '*a')

    if valid then
        ok(string.format([[Backend configuration file [%s] found and valid ]], path))
    else
        error(string.format(
            [[Backend configuration file [%s] invalid
        Please check the doc in github: [https://github.com/JuanZoran/Trans.nvim]
        ]],
            path
        ))
    end
end

local function check()
    check_database()
    check_neovim_version()
    check_configure_file()
    check_plugin_dependencies()
    check_binary_dependencies()
end

return { check = check }
