local curl = {}

curl.get = function(uri, opts)
    local query    = opts.query
    local output   = opts.output
    local headers  = opts.headers
    local callback = opts.callback


    -- INFO :Init Curl command with {s}ilent and {G}et
    local cmd  = { 'curl', '-GLs', uri }
    local size = #cmd
    local function insert(value)
        size = size + 1
        cmd[size] = value
    end

    -- INFO :Add headers
    if headers then
        for k, v in pairs(headers) do
            insert(('-H %q: %q'):format(k, v))
        end
    end

    -- INFO :Add arguments
    if query then
        for k, v in pairs(query) do
            insert(('--data-urlencode %q=%q'):format(k, v))
        end
    end

    -- INFO :Store output to file
    if output then
        insert(('-o %q'):format(output))
    end

    -- INFO : Start a job
    local outputs = {}
    local on_stdout = function(_, stdout)
        local str = table.concat(stdout)
        if str ~= '' then
            outputs[#outputs + 1] = str
        end
    end

    local error = {}
    local on_stderr = function(_, stderr)
        error[#error + 1] = table.concat(stderr)
    end

    local on_exit = function(_, exit)
        if callback then
            callback {
                exit = exit,
                body = table.concat(outputs),
                error = error
            }
        end
    end

    -- vim.pretty_print(table.concat(cmd, ' '))
    vim.fn.jobstart(table.concat(cmd, ' '), {
        stdin = 'null',
        on_stdout = on_stdout,
        on_stderr = on_stderr,
        on_exit = on_exit,
    })
end


---- TODO :
-- curl.post = function ()
--
-- end

return curl
