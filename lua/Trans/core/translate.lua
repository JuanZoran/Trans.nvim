local Trans = require('Trans')
local util = Trans.util

local function new_data(opts)
    opts = opts or {}
    local mode = opts.method or ({
        n = 'normal',
        v = 'visual',
    })[vim.api.nvim_get_mode().mode]

    local str = util.get_str(mode)
    if str == '' then return end

    local strategy = Trans.conf.strategy[mode]
    local data = {
        str = str,
        mode = mode,
        frontend = strategy.frontend,
        backend = strategy.backend,
        result = {},
    }

    if util.is_English(str) then
        data.from = 'en'
        data.to = 'zh'
    else
        data.from = 'zh'
        data.to = 'en'
    end

    -- TODO : Check if the str is a word
    data.is_word = true

    return data
end

local function set_result(data)
    local backend_list = data.backend
    local backends = Trans.backend


    local frontend = Trans.frontend[data.frontend]

    -- HACK :Rewrite this function to support multi request
    local function do_query(name)
        local backend = backends[name]
        if backend.no_wait then
            backend.query(data)
        else
            backend.query(data)
            frontend.wait(data.result, name, backend.timeout)
        end

        return type(data.result[name]) == "table"
    end

    for _, name in ipairs(backend_list) do
        if do_query(name) then
            -- TODO : process data
            break
        end
    end
end

local function render_window(data)
    -- TODO
    print('begin to render window')
end

-- HACK : Core process logic
local function process(opts)
    Trans.translate = coroutine.wrap(process)

    local data = new_data(opts)
    if not data then return end

    set_result(data)
    local success = false
    for _, v in pairs(data.result) do
        if type(v) == "table" then
            success = true
            break
        end
    end

    vim.pretty_print(data)
    if success == false then return end
    render_window(data)
end

return coroutine.wrap(process)
