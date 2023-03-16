local Trans = require('Trans')

-- FIXME :Adjust Window Size

---@class TransHover: TransFrontend
---@field ns integer @namespace for hover window
---@field buffer TransBuffer @buffer for hover window
---@field window TransWindow @hover window
---@field queue TransHover[] @hover queue for all hover instances
---@field destroy_funcs fun(hover:TransHover)[] @functions to be executed when hover window is closed
---@field opts TransHoverOpts @options for hover window
---@field pin boolean @whether hover window is pinned
local M = Trans.metatable('frontend.hover', {
    ns    = vim.api.nvim_create_namespace('TransHoverWin'),
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


        if self.window:is_valid() then self.window:try_close() end
        if self.buffer:is_valid() then self.buffer:destroy() end
        self.pin = false
    end)()
end

---Init hover window
---@param opts?
---|{width?: integer, height?: integer, col?: integer, row?: integer, relative?: string}
---@return unknown
function M:init_window(opts)
    opts           = opts or {}
    local m_opts   = self.opts
    local option   = {
        ns        = self.ns,
        buffer    = self.buffer,
        animation = m_opts.animation,
    }

    local win_opts = {
        col      = opts.col or 1,
        row      = opts.row or 1,
        title    = m_opts.title,
        relative = opts.relative or 'cursor',
        width    = opts.width or m_opts.width,
        height   = opts.height or m_opts.height,
    }

    if win_opts.title then
        win_opts.title_pos = 'center'
    end

    option.win_opts = win_opts
    self.window = Trans.window.new(option)
    return self.window
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
        buffer:add_highlight(1, 'TransWaitting')
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
    local opts = self.opts
    buffer:wipe()
    local fallback_msg = opts.fallback_message:gsub('{{(%w+)}}', opts.icon)

    -- TODO :Center
    buffer[1] = Trans.util.center(fallback_msg, opts.width)
    buffer:add_highlight(1, 'TransFailed')
    self:defer()
end

---Defer function when process done
function M:defer()
    self.window:set('wrap', true)
    self.buffer:set('modifiable', false)


    local auto_close_events = self.opts.auto_close_events
    if auto_close_events then
        vim.api.nvim_create_autocmd(auto_close_events, {
            once = true,
            callback = function()
                if self.pin then return end
                self:destroy()
            end,
        })
    end
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
    local opts = self.opts
    if opts.auto_play then
        (data.from == 'en' and data.str or result.definition[1]):play()
    end
    -- local node = Trans.util.node
    -- local it, t, f = node.item, node.text, node.format
    -- self.buffer:setline(it('hello', 'MoreMsg'))

    local buffer = self.buffer
    if not buffer:is_valid() then
        buffer:init()
    else
        buffer:wipe()
    end

    ---@cast name string
    self:load(result, name, opts.order[name])

    local display_size = Trans.util.display_size(buffer:lines(), opts.width)
    local window = self.window
    if window and window:is_valid() then
        if opts.auto_resize then
            display_size.width = math.min(opts.width, display_size.width + opts.padding)
        else
            display_size.width = nil
        end
        window:resize(display_size)
    else
        window = self:init_window {
            height = math.min(opts.height, display_size.height),
            width = math.min(opts.width, display_size.width + opts.padding),
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
--     local cmd_id
--     local next
--     local action = {
--         pageup = function()
--             buffer:normal('gg')
--         end,

--         pagedown = function()
--             buffer:normal('G')
--         end,

--         pin = function()
--             if lock then
--                 error('请先关闭窗口')
--             else
--                 lock = true
--             end
--             pcall(api.nvim_del_autocmd, cmd_id)
--             local width, height = win.width, win.height
--             local col = vim.o.columns - width - 3
--             local buf = buffer.bufnr
--             local run = win:try_close()
--             run(function()
--                 local w, r = open_window {
--                     width = width,
--                     height = height,
--                     relative = 'editor',
--                     col = col,
--                 }

--                 next = w.winid
--                 win = w
--                 r(function()
--                     w:set('wrap', true)
--                 end)

--                 del('n', keymap.pin)
--                 api.nvim_create_autocmd('BufWipeOut', {
--                     callback = function(opt)
--                         if opt.buf == buf or opt.buf == cur_buf then
--                             lock = false
--                             api.nvim_del_autocmd(opt.id)
--                         end
--                     end
--                 })
--             end)
--         end,

--         close = function()
--             pcall(api.nvim_del_autocmd, cmd_id)
--             local run = win:try_close()
--             run(function()
--                 buffer:delete()
--             end)
--             try_del_keymap()
--         end,

--         toggle_entry = function()
--             if lock and win:is_valid() then
--                 local prev = api.nvim_get_current_win()
--                 api.nvim_set_current_win(next)
--                 next = prev
--             else
--                 del('n', keymap.toggle_entry)
--             end
--         end,

--         play = function()
--             if word then
--                 word:play()
--             end
--         end,
--     }
--     local set = vim.keymap.set
--     for act, key in pairs(hover.keymap) do
--         set('n', key, action[act])
--     end


--     if hover.auto_close_events then
--         cmd_id = api.nvim_create_autocmd(
--             hover.auto_close_events, {
--             buffer = 0,
--             callback = action.close,
--         })
--     end
-- end
