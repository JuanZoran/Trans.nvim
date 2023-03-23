---@type Trans
local Trans = require("Trans")

-- FIXME :Adjust Window Size

---@class TransHover: TransFrontend
---@field ns integer @namespace for hover window
---@field buffer TransBuffer @buffer for hover window
---@field window TransWindow @hover window
---@field queue TransHover[] @hover queue for all hover instances
---@field destroy_funcs fun(hover:TransHover)[] @functions to be executed when hover window is closed
---@field opts TransHoverOpts @options for hover window
---@field pin boolean @whether hover window is pinned
local M = Trans.metatable("frontend.hover", {
    ns = vim.api.nvim_create_namespace("TransHoverWin"),
    queue = {},
})
M.__index = M

---Create a new hover instance
---@return TransHover new_instance
function M.new()
    local new_instance = {
        pin = false,
        buffer = Trans.buffer.new(),
        destroy_funcs = {},
    }
    M.queue[#M.queue + 1] = new_instance

    new_instance.buffer:deleteline(1)
    return setmetatable(new_instance, M)
end

---Get the first active instances
---@return TransHover
function M.get_active_instance()
    M.clear_dead_instance()
    return M.queue[#M.queue]
end

---Clear dead instance
function M.clear_dead_instance()
    local queue = M.queue
    for i = #queue, 1, -1 do
        if not queue[i]:is_available() then
            queue[i]:destroy()
            table.remove(queue, i)
        end
    end
end

---Destroy hover instance and execute destroy functions
function M:destroy()
    coroutine.wrap(function()
        for _, func in ipairs(self.destroy_funcs) do
            func(self)
        end

        if self.window:is_valid() then
            self.window:try_close()
        end
        if self.buffer:is_valid() then
            self.buffer:destroy()
        end
        self.pin = false
    end)()
end

---Init hover window
---@param opts?
---|{width?: integer, height?: integer, col?: integer, row?: integer, relative?: string}
---@return unknown
function M:init_window(opts)
    opts = opts or {}
    local m_opts = self.opts
    local option = {
        buffer = self.buffer,
        animation = m_opts.animation,
    }

    -- stylua: ignore start
    local win_opts = {
        col      = opts.col or 1,
        row      = opts.row or 1,
        title    = m_opts.title,
        width    = opts.width or m_opts.width,
        height   = opts.height or m_opts.height,
        relative = opts.relative or "cursor",
    }
    -- stylua: ignore end

    if win_opts.title then
        win_opts.title_pos = "center"
    end

    option.win_opts = win_opts
    self.window = Trans.window.new(option)
    return self.window
end

---Get Formatted icon text
---@param format string format string
---@return string formatted text
---@return integer _ replaced count
function M:icon_format(format)
    return format:gsub("{{(%w+)}}", self.opts.icon)
end

---Get Check function for waiting
---@return function
function M:wait()
    local cur      = 0
    local opts     = self.opts
    local buffer   = self.buffer
    local times    = opts.width
    local pause    = Trans.util.pause
    local cell     = opts.icon.cell
    local spinner  = Trans.style.spinner[opts.spinner]
    local size     = #spinner
    local interval = math.floor(opts.timeout / opts.width)

    self:init_window {
        height = 1,
        width = times,
    }

    return function()
        cur = cur + 1
        buffer[1] = spinner[cur % size + 1] .. (cell):rep(cur)
        buffer:add_highlight(1, "TransWaitting")
        pause(interval)
        return cur < times
    end
end

---FallBack window for no result
function M:fallback()
    if not self.window then
        self:init_window {
            height = 1,
            width = self.opts.width,
        }
    end

    local buffer = self.buffer
    buffer:wipe()

    local opts = self.opts
    local fallback_msg = self:icon_format(opts.fallback_message)

    -- TODO :Center
    buffer[1] = Trans.util.center(fallback_msg, opts.width)
    buffer:add_highlight(1, "TransFailed")
    self:defer()
end

---Defer function when process done
function M:defer()
    self.window:set("wrap", true)
    self.buffer:set("modifiable", false)

    local auto_close_events = self.opts.auto_close_events
    if not auto_close_events then return end

    vim.api.nvim_create_autocmd(auto_close_events, {
        callback = function(opts)
            vim.defer_fn(function()
                if not self.pin and vim.api.nvim_get_current_win() ~= self.window.winid then
                    pcall(vim.api.nvim_del_autocmd, opts.id)
                    self:destroy()
                end
            end, 0)
        end,
    })
end

---Display Result in hover window
---@param data TransData
---@overload fun(result:TransResult)
function M:process(data)
    if self.pin then return end

    local result, name = data:get_available_result()
    if not result then
        self:fallback()
        return
    end

    local opts   = self.opts
    local util   = Trans.util
    local buffer = self.buffer

    if opts.auto_play then
        (data.from == "en" and data.str or result.definition[1]):play()
    end

    -- vim.pretty_print(result)
    util.main_loop(function()
        if not buffer:is_valid() then
            buffer:init()
        else
            buffer:wipe()
        end

        ---@cast name string
        self:load(result, name, opts.order[name])
    end)

    local window = self.window
    local lines = buffer:lines()


    local width =
        window and window:is_valid() and
            (opts.auto_resize and
                math.max(
                    math.min(opts.width, util.display_width(lines) + opts.padding),
                    math.min(data.str:width(), opts.split_width)
                )
            or opts.width)
        or math.min(opts.width, util.display_width(lines) + opts.padding)

    local height = math.min(opts.height, util.display_height(lines, width))

    if window and window:is_valid() then
        window:resize { width = width, height = height }
    else
        window = self:init_window {
            height = height,
            width = width,
        }
    end

    self:defer()
end

---Check if hover window and buffer are valid
---@return boolean @whether hover window and buffer are valid
function M:is_available()
    return self.buffer:is_valid() and self.window:is_valid()
end

---@class TransFrontend
---@field hover TransHover @hover frontend
return M
