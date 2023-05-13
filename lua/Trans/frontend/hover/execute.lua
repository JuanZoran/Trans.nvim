local api = vim.api

---@type table<string, fun(hover: TransHover)>
local strategy = {
    pageup = function(hover)
        hover.buffer:normal 'gg'
    end,

    pagedown = function(hover)
        hover.buffer:normal 'G'
    end,

    pin = function(hover)
        if hover.pin then
            return
        end
        hover.pin = true
        local window = hover.window
        local width, height = window:width(), window:height()
        local col = vim.o.columns - width - 3
        window:try_close()

        window = hover:init_window {
            col      = col,
            width    = width,
            height   = height,
            relative = 'editor',
        }

        window:set('wrap', true)
    end,

    close = function(hover)
        hover:destroy()
    end,

    toggle_entry = function(hover)
        if api.nvim_get_current_win() ~= hover.window.winid then
            api.nvim_set_current_win(hover.window.winid)
            return
        end

        for _, winid in ipairs(api.nvim_list_wins()) do
            if winid ~= hover.window.winid then
                api.nvim_set_current_win(winid)
                break
            end
        end
    end,
}

---@class TransHover
---@field execute fun(hover: TransHover, action: string)
return function(hover, action)
    return strategy[action](hover)
end

-- This function will be called within coroutine, so we can't use __call
-- return setmetatable(strategy, {
--     __call = function(_, hover, action)
--         return strategy[action](hover)
--     end,
-- })
