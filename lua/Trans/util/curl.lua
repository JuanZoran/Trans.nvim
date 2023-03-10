--- TODO :wrapper for curl
local curl = {}

---Send a GET request
---@param opts table
curl.GET = function(opts)
    local uri = opts.uri
    local headers = opts.headers or {}
    local callback = opts.callback

    -- INFO :Init Curl command with {s}ilent and {G}et
    local cmd = { 'curl', '-Gs' }

    -- INFO :Add headers
    for k, v in pairs(headers) do
        cmd[#cmd + 1] = ([[-H '%s: %s']]):format(k, v)
    end

    -- INFO :Add arguments
    local info = {}
    for k, v in pairs(opts.arguments) do
        info[#info + 1] = ('%s=%s'):format(k, v)
    end
    cmd[#cmd + 1] = ([['%s?%s']]):format(uri, table.concat(info, '&'))


    -- write a function to get the output
    local outpus = {}
    vim.fn.jobstart(table.concat(cmd, ' '), {
        stdin = 'null',
        on_stdout = function(_, stdout)
            local str = table.concat(stdout)
            if str ~= '' then

            end
        end,
        on_exit = function()
            callback(output)
        end,
    })

    -- local output = ''
    -- local option = {
    --     stdin = 'null',
    --     on_stdout = function(_, stdout)
    --         local str = table.concat(stdout)
    --         if str ~= '' then
    --             output = output .. str
    --         end
    --     end,
    --     on_exit = function()
    --         callback(output)
    --     end,
    -- }

    -- vim.fn.jobstart(table.concat(cmd, ' '), option)
end



curl.POST = function(opts)
    vim.validate {
        uri = { uri, 's' },
        opts = { opts, 't' }
    }

    local callback = opts.callback

    local cmd = { 'curl', '-s', ('"%s"'):format(uri) }
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
