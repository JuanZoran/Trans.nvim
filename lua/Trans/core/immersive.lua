local function trans()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local paragraphs = {}

    -- TODO : trim empty lines in the beginning and the end
    for index, line in ipairs(lines) do
        if line:match '%S+' then
            table.insert(paragraphs, { index - 1, line })
        end
    end


    local Trans = require 'Trans'
    local baidu = Trans.backend.baidu
    ---@cast baidu Baidu

    for _, line in ipairs(paragraphs) do
        local query = baidu.get_query {
            str = line[2],
            from = 'en',
            to = 'zh',
        }

        Trans.curl.get(baidu.uri, {
            query = query,
            callback = function(output)
                -- vim.print(output)
                local body = output.body
                local status, ret = pcall(vim.json.decode, body)
                assert(status and ret, 'Failed to parse json:' .. vim.inspect(body))
                local result = ret.trans_result
                assert(result, 'Failed to get result: ' .. vim.inspect(ret))


                result = result[1]
                line.translation = result.dst
            end,
        })
    end

    local ns = vim.api.nvim_create_namespace 'Trans'
    for _, line in ipairs(paragraphs) do
        local index = line[1]
        local co = coroutine.running()
        local times = 0
        while not line.translation do
            vim.defer_fn(function()
                coroutine.resume(co)
            end, 100)

            print('waitting' .. ('.'):rep(times))
            times = times + 1
            -- if times == 10 then break end
            coroutine.yield()
        end


        local translation = line.translation
        print(translation, index)
        Trans.util.main_loop(function()
            vim.api.nvim_buf_set_extmark(0, ns, index, #line[2], {
                virt_lines = {
                    { { translation, 'MoreMsg' } },
                },
            })
        end)

        print 'done'
    end
    -- TODO :双语翻译
end

return function()
    coroutine.wrap(trans)()
end
