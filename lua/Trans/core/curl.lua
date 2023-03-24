---@class TransCurl
local curl = {}

---@class RequestResult
---@field body string
---@field exit integer exit code
---@field error string error message from stderr


---@class TransCurlOptions
---@field query table<string, string> query arguments
---@field output string output file path
---@field headers table<string, string> headers
---@field callback fun(result: RequestResult)


---@async
---Send a GET request use curl
---@param uri string uri for request
---@param opts
---| { query?: table<string, string>, output?: string, headers?: table<string, string>, callback: fun(result: RequestResult), extra?: string[] }
function curl.get(uri, opts)
    local query    = opts.query
    local output   = opts.output
    local headers  = opts.headers
    local callback = opts.callback
    local extra    = opts.extra


    -- INFO :Init Curl command with {s}ilent and {G}et
    local cmd  = vim.list_extend({ 'curl', '-GLs', uri }, extra or {})
    local size = #cmd
    local function add(value)
        size = size + 1
        cmd[size] = value
    end

    -- INFO :Add headers
    if headers then
        for k, v in pairs(headers) do
            add(('-H %q: %q'):format(k, v))
        end
    end

    -- INFO :Add arguments
    if query then
        for k, v in pairs(query) do
            add(('--data-urlencode %q=%q'):format(k, v))
        end
    end

    -- INFO :Store output to file
    if output then
        add(('-o %q'):format(output))
    end

    -- INFO : Start a job
    local outputs = {}
    local on_stdout = function(_, stdout)
        local str = table.concat(stdout)
        if str ~= '' then
            outputs[#outputs + 1] = str
        end
    end


    local on_exit = function(_, exit)
        callback {
            exit = exit,
            body = table.concat(outputs),
        }
    end

    -- vim.print(table.concat(cmd, ' '))
    vim.fn.jobstart(table.concat(cmd, ' '), {
        stdin = 'null',
        on_stdout = on_stdout,
        on_exit = on_exit,
    })
end

--- TODO :
-- curl.post = function ()
--
-- end


---@class Trans
---@field curl TransCurl
return curl
