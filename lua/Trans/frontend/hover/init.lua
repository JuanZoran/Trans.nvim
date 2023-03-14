local Trans = require('Trans')

---@class hover
---@field queue table @hover queue for all hover instances
---@field buffer buf @buffer for hover window
---@field destroy_funcs table @functions to be executed when hover window is closed
---@field window window @hover window
---@field opts table @options for hover window
---@field opts.title string @title for hover window
---@field opts.width number @width for hover window
---@field opts.height number @height for hover window
---@field opts.animation boolean @whether to use animation for hover window
---@field opts.fallback_message string @message to be displayed when hover window is waiting for data
---@field opts.spinner string @spinner to be displayed when hover window is waiting for data
---@field opts.icon table @icons for hover window
---@field opts.icon.notfound string @icon for not found
---@field opts.icon.yes string @icon for yes
---@field opts.icon.no string @icon for no
---@field opts.icon.star string @icon for star
---@field opts.icon.cell string @icon for cell used in waitting animation


local M = Trans.metatable('frontend.hover', {
    ns    = vim.api.nvim_create_namespace('TransHoverWin'),
    queue = {},
})
M.__index = M

---Create a new hover instance
---@return hover new_instance
function M.new()
    local new_instance = {
        buffer = Trans.buffer.new(),
        destroy_funcs = {},
    }
    M.queue[#M.queue + 1] = new_instance

    return setmetatable(new_instance, M)
end

---Get the first active instances
---@return hover
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
---@param opts table? @window options: width, height
---@return unknown
function M:init_window(opts)
    opts           = opts or {}
    local win_opts = opts.win_opts or {}
    opts.win_opts  = win_opts
    local m_opts   = self.opts


    opts.ns           = self.ns
    opts.buffer       = self.buffer
    win_opts.col      = 1
    win_opts.row      = 1
    win_opts.relative = 'cursor'
    win_opts.title    = m_opts.title
    if win_opts.title then
        win_opts.title_pos = 'center'
    end
    win_opts.width  = win_opts.width or m_opts.width
    win_opts.height = win_opts.height or m_opts.height
    opts.animation  = m_opts.animation


    self.window = Trans.window.new(opts)
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
        win_opts = {
            height = 1,
            width = width,
        }
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

    -- TODO : End waitting animation
    buffer[1] = ''
end

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

    local win = self.window
    if win and win:is_valid() then
        win:resize { self.opts.width, self.opts.height }
    else
        win = self:init_window()
    end

    win:set('wrap', true)
end

---Check if hover window and buffer are valid
---@return boolean @whether hover window and buffer are valid
function M:is_available()
    return self.buffer:is_valid() and self.window:is_valid()
end

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
