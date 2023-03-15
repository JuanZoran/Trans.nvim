local Trans = require('Trans')

-- FIXME :Adjust Window Size

---@class TransHover: TransFrontend
---@field ns integer @namespace for hover window
---@field buffer TransBuffer @buffer for hover window
---@field window TransWindow @hover window
---@field queue TransHover[] @hover queue for all hover instances
---@field destroy_funcs fun(hover:TransHover)[] @functions to be executed when hover window is closed
---@field opts TransHoverOpts @options for hover window
local M = Trans.metatable('frontend.hover', {
    ns    = vim.api.nvim_create_namespace('TransHoverWin'),
    queue = {},
})
M.__index = M

---Create a new hover instance
---@return TransHover new_instance
function M.new()
    local new_instance = {
        buffer = Trans.buffer.new(),
        destroy_funcs = {},
    }
    M.queue[#M.queue + 1] = new_instance

    return setmetatable(new_instance, M)
end

---Get the first active instances
---@return TransHover
function M.get_active_instance()
    M.clear_dead_instance()
    return M.queue[1]
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
    for _, func in ipairs(self.destroy_funcs) do
        func(self)
    end


    if self.window:is_valid() then self.window:try_close() end
    if self.buffer:is_valid() then self.buffer:destroy() end
end

---Init hover window
---@param opts?
---|{width?: integer, height?: integer}
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
        col      = 1,
        row      = 1,
        relative = 'cursor',
        title    = m_opts.title,
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

---Wait for data
---@param tbl table @table to be checked
---@param name string @key to be checked
---@param timeout number @timeout for waiting
function M:wait(tbl, name, timeout)
    local opts    = self.opts
    local width   = opts.width
    local spinner = Trans.style.spinner[self.opts.spinner]
    local size    = #spinner
    local cell    = self.opts.icon.cell

    local function update_text(times)
        return spinner[times % size + 1] .. (cell):rep(times)
    end


    self:init_window({
        height = 1,
        width = width,
    })


    local interval = math.floor(timeout / width)
    local pause = Trans.util.pause
    local buffer = self.buffer
    for i = 1, width do
        if tbl[name] ~= nil then break end
        buffer[1] = update_text(i)
        buffer:add_highlight(1, 'MoreMsg')
        pause(interval)
    end


    -- FIXME :
    -- vim.api.nvim_buf_set_lines(buffer.bufnr, 1, -1, true, { '' })
    -- print('jklajsdk')
    -- print(vim.fn.deletebufline(buffer.bufnr, 1))
    -- buffer:del()
    buffer[1] = ''
end


---Display Result in hover window
---@param _ TransData
---@param result TransResult
---@overload fun(result:TransResult)
function M:process(_, result)
    -- local node = Trans.util.node
    -- local it, t, f = node.item, node.text, node.format
    -- self.buffer:setline(it('hello', 'MoreMsg'))
    local opts = self.opts

    for _, field in ipairs(opts.order) do
        if result[field] then
            self:load(result, field)
        end
    end

    local window = self.window
    local display_size = Trans.util.display_size(self.buffer:lines(), opts.width)
    if window and window:is_valid() then
        -- win:adjust_height(opts.height)
        display_size.width = math.min(opts.width, display_size.width + 6)
        window:resize(display_size)
    else
        window = self:init_window {
            height = math.min(opts.height, display_size.height),
            width = math.min(opts.width, display_size.width),
        }
    end

    window:set('wrap', true)
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
