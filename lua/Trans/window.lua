local api = vim.api
local display = require('Trans.util.display')

---@class win
---@field winid integer window handle
---@field width integer
---@field height integer
---@field ns integer namespace for highlight
---@field animation table window animation
---@field buf buf buffer for attached
local window = {}

---Change window attached buffer
---@param buf buf
function window:set_buf(buf)
    api.nvim_win_set_buf(self.winid, buf.bufnr)
    self.buf = buf
end

---Check window valid
---@return boolean
function window:is_valid()
    return api.nvim_win_is_valid(self.winid)
end

---Set window option
---@param option string option name
---@param value any
function window:set(option, value)
    if self:is_valid() then
        api.nvim_win_set_option(self.winid, option, value)
    end
end

---@param name string option name
---@return any
function window:option(name)
    return api.nvim_win_get_option(self.winid, name)
end

---@param height integer
function window:set_height(height)
    api.nvim_win_set_height(self.winid, height)
    self.height = height
end

---@param width integer
function window:set_width(width)
    api.nvim_win_set_width(self.winid, width)
    self.width = width
end

---Expand window [width | height] value
---@param opts table
---|'field'string [width | height]
---|'target'integer
---@return function
function window:expand(opts)
    self:lock()
    local field  = opts.field
    local target = opts.target
    local cur    = self[field]
    local times  = math.abs(target - cur)

    local wrap = self:option('wrap')
    self:set('wrap', false)
    local interval = opts.interval or self.animation.interval
    local method = api['nvim_win_set_' .. field]

    local winid = self.winid
    local frame = target > cur and function(_, cur_times)
        method(winid, cur + cur_times)
    end or function(_, cur_times)
        method(winid, cur - cur_times)
    end

    local run = display {
        times    = times,
        frame    = frame,
        interval = interval,
    }

    run(function()
        self:set('wrap', wrap)
        self[field] = target
        self:unlock()
    end)
    return run
end

---Close window
---@return function run run until close done
function window:try_close()
    local field = ({
        slid = 'width',
        fold = 'height',
    })[self.animation.close]

    --- 播放动画
    local run = self:expand {
        field = field,
        target = 1,
    }

    run(function()
        api.nvim_win_close(self.winid, true)
    end)
    return run
end

---lock window [open | close] operation
function window:lock()
    while self.busy do
        vim.wait(50)
    end
    self.busy = true
end

function window:unlock()
    self.busy = false
end

---设置窗口本地的高亮组
---@param name string 高亮组的名称
---@param opts table 高亮选项
function window:set_hl(name, opts)
    api.nvim_set_hl(self.ns, name, opts)
end

---buffer:addline() helper function
---@param node table
---@return table node formatted node
function window:center(node)
    local text = node[1]
    local width = text:width()
    local win_width = self.width
    local space = math.max(math.floor((win_width - width) / 2), 0)
    node[1] = (' '):rep(space) .. text
    return node
end

---@private
window.__index = window

---@class win_opts
---@field buf buf buffer for attached
---@field height integer
---@field width integer
---@field col integer
---@field row integer
---@field border string
---@field title string | nil | table
---@field relative string
---@field ns integer namespace for highlight
---@field zindex? integer
---@field enter? boolean cursor should [enter] window
---@field animation table window animation

---window constructor
---@param opts win_opts
---@return table
---@return function
return function(opts)
    assert(type(opts) == 'table')
    local ns        = opts.ns
    local buf       = opts.buf
    local col       = opts.col
    local row       = opts.row
    local title     = opts.title
    local width     = opts.width
    local enter     = opts.enter or false
    local height    = opts.height
    local border    = opts.border
    local zindex    = opts.zindex
    local relative  = opts.relative
    local animation = opts.animation

    local open = animation.open

    local field = ({
        slid = 'width',
        fold = 'height',
    })[open]

    local win_opt = {
        title_pos = nil,
        focusable = false,
        style     = 'minimal',
        zindex    = zindex,
        width     = width,
        height    = height,
        col       = col,
        row       = row,
        border    = border,
        title     = title,
        relative  = relative,
    }

    if field then
        win_opt[field] = 1
    end

    if win_opt.title then
        win_opt.title_pos = 'center'
    end

    local win = setmetatable({
        buf       = buf,
        ns        = ns,
        height    = win_opt.height,
        width     = win_opt.width,
        animation = animation,
        winid     = api.nvim_open_win(buf.bufnr, enter, win_opt),
    }, window)

    api.nvim_win_set_hl_ns(win.winid, win.ns)
    win:set_hl('Normal', { link = 'TransWin' })
    win:set_hl('FloatBorder', { link = 'TransBorder' })

    return win, win:expand {
        field = field,
        target = opts[field],
    }
end
