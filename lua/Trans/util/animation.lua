local animation = {
    display = function(self)
        local callback = self.callback or function ()

        end

        if self.sync then
            local times = self.times
            if times then
                for i = 1, self.times do
                    if self.run then
                        self:frame(i)
                    end
                end
            else
                while self.run do
                    self:frame()
                end
                callback()
            end

        else
            local frame
            if self.times then
                local target = self.times
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
    end,
}

animation.__index = animation

return function(opts)
    opts.run = true
    return setmetatable(opts, animation)
end
