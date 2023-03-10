local M = {}
M.test_api_latency = function(urls)
    urls = type(urls) == 'string' and { urls } or urls

    local f = [[curl -s -o /dev/null -w '[%s]延迟: %%{time_total}s %s']]
    local result = {}
    for _, url in ipairs(urls) do
        local cmd = string.format(f, url, url)
        local res = vim.fn.system(cmd)
        result[#result + 1] = res
    end

    vim.pretty_print(result)
end

return M
