return function(opts)
    local callback = opts.callback or function()

    end
    opts.run = true

    local target = opts.times
    if opts.sync then
        if target then
            for i = 1, target do
                if opts.run then
                    opts:frame(i)
                end
            end

        else
            while opts.run do
                opts:frame()
            end
        end

        callback()

    else
        local frame
        if target then
            local times = 0
            frame = function()
                if opts.run and times < target then
                    times = times + 1
                    opts:frame(times)
                    vim.defer_fn(frame, opts.interval)
                else
                    callback()
                end
            end

        else
            frame = function()
                if opts.run then
                    opts:frame()
                    vim.defer_fn(frame, opts.interval)
                else
                    callback()
                end
            end
        end
        frame()
    end
    return opts
end
