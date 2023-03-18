local Trans = require('Trans')
local util = Trans.util

local function init_opts(opts)
    opts = opts or {}
    opts.mode = opts.mode or ({
        n = 'normal',
        v = 'visual',
    })[vim.api.nvim_get_mode().mode]

    opts.str = util.get_str(opts.mode)
    return opts
end


local function do_query(data, backend)
    -- TODO : template method for online query
    local name      = backend.name
    local uri       = backend.uti
    local method    = backend.method
    local formatter = backend.formatter
    local query     = backend.get_query(data)

    local header
    if backend.header then
        if type(backend.header) == "function" then
            header = backend.header(data)
        else
            header = backend.header
        end
    end

    local function handle(output)
        local status, body = pcall(vim.json.decode, output.body)
        -- -- vim.print(body)
        if not status or not body or body.errorCode ~= "0" then
            if not Trans.conf.debug then backend.debug(body) end
            data.result[name] = false
            data[#data + 1] = output
            return
        end
        -- check_untracked_field(body)
        -- if not body.isWord then
        --     data.result.youdao = {
        --         title = body.query,
        --         [data.from == 'en' and 'translation' or 'definition'] = body.translation,
        --     }
        --     return
        -- end
        -- local tmp = {
        --     title    = {
        --         word     = body.query,
        --         phonetic = body.basic.phonetic,
        --     },
        --     web      = body.web,
        --     explains = body.basic.explains,
        --     -- phrases                                               = body.phrases,
        --     -- synonyms                                              = body.synonyms,
        --     -- sentenceSample                                        = body.sentenceSample,
        --     [data.from == 'en' and 'translation' or 'definition'] = body.translation,
        -- }
        data.result[name] = formatter and formatter(output) or output
    end

    Trans.curl[method](uri, {
        query = query,
        callback = handle,
        header = header,
    })
    -- Hook ?
end


---@type table<string, fun(data: TransData): true | nil>
local strategy = {
    fallback = function(data)
        local result = data.result
        Trans.backend.offline.query(data)
        if result.offline then return true end


        local update = data.frontend:wait()
        for _, backend in ipairs(data.backends) do
            ---@cast backend TransBackend
            backend.query(data)
            local name = backend.name

            while result[name] == nil do
                if not update() then return end
            end

            if result[name] then return true end
        end
    end,
    --- TODO :More Strategys
}



-- HACK : Core process logic
local function process(opts)
    opts = init_opts(opts)
    local str = opts.str
    if not str or str == '' then return end

    -- Find in cache
    if Trans.cache[str] then
        local data = Trans.cache[str]
        data.frontend:process(data)
        return
    end

    local data = Trans.data.new(opts)
    if strategy[Trans.conf.query](data) then
        Trans.cache[data.str] = data
        data.frontend:process(data)
    else
        data.frontend:fallback()
    end
end


---@class Trans
---@field translate fun(opts: { frontend: string?, mode: string?}?) Translate string core function
return function(opts)
    coroutine.wrap(process)(opts)
end
