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
---@field extra string[]
---@field progress fun(percent: number, message: string)
---@field silent boolean


---@async
---Send a GET request use curl
---@param uri string uri for request
---@param opts
---| { query?: table<string, string>, output?: string, headers?: table<string, string>, callback: fun(result: RequestResult), extra?: string[], progress?: fun(percent: number, message: string), silent?: boolean }
function curl.get(uri, opts)
    local query    = opts.query
    local output   = opts.output
    local headers  = opts.headers
    local callback = opts.callback
    local extra    = opts.extra
    local progress = opts.progress
    local silent   = opts.silent ~= false

    local cmd = { 'curl', '-GL' }
    local size = #cmd
    local function add(value)
        size = size + 1
        cmd[size] = value
    end

    if progress then
        add('--progress-bar')
    elseif silent then
        add('-s')
    end

    add(uri)

    if extra then
        for _, value in ipairs(extra) do
            add(value)
        end
    end

    if headers then
        for k, v in pairs(headers) do
            add(('-H %q: %q'):format(k, v))
        end
    end

    if query then
        for k, v in pairs(query) do
            add(('--data-urlencode %q=%q'):format(k, v))
        end
    end

    if output then
        add(('-o %q'):format(output))
    end

    local outputs = {}
    local stderr_outputs = {}
    local function collect_percent(text)
        local percent
        for match in text:gmatch('(%d?%d?%d)%%') do
            percent = tonumber(match)
        end
        return percent
    end

    local on_stdout = function(_, stdout)
        local str = table.concat(stdout)
        if str ~= '' then
            outputs[#outputs + 1] = str
        end
    end

    local on_stderr = function(_, stderr)
        local str = table.concat(stderr)
        if str ~= '' then
            stderr_outputs[#stderr_outputs + 1] = str
            if progress then
                local percent = collect_percent(str)
                if percent then
                    vim.schedule(function()
                        progress(percent, str)
                    end)
                end
            end
        end
    end

    local on_exit = function(_, exit)
        callback {
            exit = exit,
            body = table.concat(outputs),
            error = table.concat(stderr_outputs),
        }
    end

    vim.fn.jobstart(table.concat(cmd, ' '), {
        stdin = 'null',
        on_stdout = on_stdout,
        on_stderr = on_stderr,
        on_exit = on_exit,
    })
end

---@class Trans
---@field curl TransCurl
return curl
