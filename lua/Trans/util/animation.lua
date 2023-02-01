local display = function(self)
    local callback = self.callback or function()

    end

    local target = self.times
    if self.sync then
        if target then
            for i = 1, target do
                if self.run then
                    self:frame(i)
                end
            end

        else
            while self.run do
                self:frame()
            end
        end

        callback()
    else
        local frame
        if target then
            local times = 0
            frame = function()
                if self.run and times < target then
                    times = times + 1
                    self:frame(times)
                    vim.defer_fn(frame, self.interval)
                else
                    callback()
                end
            end

        else
            frame = function()
                if self.run then
                    self:frame()
                    vim.defer_fn(frame, self.interval)
                else
                    callback()
                end
            end
        end
        frame()
    end
end


return function(opts)
    opts.run = true
    opts.display = display
    return opts
end
