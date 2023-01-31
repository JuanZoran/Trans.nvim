--- TODO :wrapper for curl
local curl = {}
-- local example = {
--     data = {},
--     headers = {
--         k = 'v',
--     },
--     callback = function(output)

--     end,
-- }

curl.GET = function(uri, opts)
    --- TODO :
end


curl.POST = function(uri, opts)
    vim.validate {
        uri = { uri, 's' },
        opts = { opts, 't' }
    }

    local callback = opts.callback

    local cmd = { 'curl', '-s', uri }
    local size = 3

    local function insert(...)
        for _, v in ipairs { ... } do
            size = size + 1
            cmd[size] = v
        end
    end

    local s = '"%s=%s"'

    if opts.headers then
        for k, v in pairs(opts.headers) do
            insert('-H', s:format(k, v))
        end
    end

    for k, v in pairs(opts.data) do
        insert('-d', s:format(k, v))
    end


    local output = ''
    local option = {
        stdin = 'null',
        on_stdout = function(_, stdout)
            local str = table.concat(stdout)
            if str ~= '' then
                output = output .. str
            end
        end,
        on_exit = function()
            callback(output)
        end,
    }

    vim.fn.jobstart(table.concat(cmd, ' '), option)
end


return curl
