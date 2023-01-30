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

    local option
    if opts.callback then
        option = {
            on_stdout = function (_, output)
                opts.callback(table.concat(output))
            end,
        }
    end

    vim.fn.jobstart(table.concat(cmd, ' '), option)
end


return curl
