return function(opts)
    local target = opts.times
    opts.run = target ~= 0

    ---@type function[]
    local tasks = {}
    local function do_task()
        for _, task in ipairs(tasks) do
            task()
        end
    end

    local frame
    if target then
        local times = 0
        frame = function()
            if opts.run and times < target then
                times = times + 1
                opts:frame(times)
                vim.defer_fn(frame, opts.interval)

            else
                do_task()
            end
        end

    else
        frame = function()
            if opts.run then
                opts:frame()
                vim.defer_fn(frame, opts.interval)
            else
                do_task()
            end
        end
    end
    frame()

    ---任务句柄, 如果任务结束了则立即执行, 否则立即执行
    ---@param task function
    return function(task)
        if opts.run then
            tasks[#tasks + 1] = task
        else
            task()
        end
    end
end
