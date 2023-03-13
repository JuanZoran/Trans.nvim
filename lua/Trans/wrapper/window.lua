local api = vim.api
local Trans = require("Trans")


---@class win
---@field win_opts table window config [**When open**]
---@field winid integer window handle
---@field ns integer namespace for highlight
---@field animation table window animation
---@field enter boolean cursor should [enter] window when open
---@field buffer buffer attached buffer object
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
end

---@param width integer
function window:set_width(width)
    api.nvim_win_set_width(self.winid, width)
end

---Get window width
function window:width()
    return api.nvim_win_get_width(self.winid)
end

---Get window height
function window:height()
    return api.nvim_win_get_height(self.winid)
end

---Expand window [width | height] value
---@param opts table
---|'field'string [width | height]
---|'target'integer
function window:smooth_expand(opts)
    local field = opts.field -- width | height
    local from  = self[field](self)
    local to    = opts.target

    if from == to then return end


    local pause  = Trans.util.pause
    local method = api['nvim_win_set_' .. field]


    local wrap = self:option('wrap')

    local interval = self.animation.interval
    for i = from + 1, to, (from < to and 1 or -1) do
        self:set('wrap', false)
        method(self.winid, i)
        pause(interval)
    end

    self:set('wrap', wrap)
end

---Try to close window with animation?
function window:try_close()
    local close_animation = self.animation.close
    if close_animation then
        local field = ({
            slid = 'width',
            fold = 'height',
        })[close_animation]

        self:smooth_expand({
            field = field,
            target = 1,
        })
    end

    api.nvim_win_close(self.winid, true)
end

---set window local highlight group
---@param name string
---@param opts table
function window:set_hl(name, opts)
    api.nvim_set_hl(self.ns, name, opts)
end

---Open window with animation?
function window:open()
    local win_opts = self.win_opts
    local open_animation = self.animation.open
    if open_animation then
        local field = ({
            slid = 'width',
            fold = 'height',
        })[open_animation]

        local to = win_opts[field]
        win_opts[field] = 1
        self.winid = api.nvim_open_win(self.buffer.bufnr, self.enter, win_opts)
        self:smooth_expand({
            field = field,
            target = to,
        })
    else
        self.winid = api.nvim_open_win(self.buffer.bufnr, self.enter, win_opts)
    end
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

window.__index = window

local default_opts = {
    ns       = api.nvim_create_namespace('TransHoverWin'),
    enter    = false,
    winid    = -1,
    win_opts = {
        style     = 'minimal',
        border    = 'rounded',
        focusable = false,
        noautocmd = true,
    },
}


---Create new window
---@param opts table window config
---@return win
function window.new(opts)
    opts = vim.tbl_deep_extend('keep', opts, default_opts)

    local win = setmetatable(opts, window)
    win:open()
    return win
end

return window

--@class win_opts
--@field buf buf buffer for attached
--@field height integer
--@field width integer
--@field col integer
--@field row integer
--@field border string
--@field title string | nil | table
--@field relative string
--@field ns integer namespace for highlight
--@field zindex? integer
--@field enter? boolean cursor should [enter] window
--@field animation table window animation

-- local ns        = opts.ns
-- local buf       = opts.buf
-- local col       = opts.col
-- local row       = opts.row
-- local title     = opts.title
-- local width     = opts.width
-- local height    = opts.height
-- local border    = opts.border
-- local zindex    = opts.zindex
-- local relative  = opts.relative
-- local animation = opts.animation

-- local open      = animation.open

-- local field     = ({
--     slid = 'width',
--     fold = 'height',
-- })[open]

-- local win_opt   = {
--     focusable = false,
--     style     = 'minimal',
--     zindex    = zindex,
--     width     = width,
--     height    = height,
--     col       = col,
--     row       = row,
--     border    = border,
--     title     = title,
--     relative  = relative,
-- }

-- if field then
--     win_opt[field] = 1
-- end

-- if win_opt.title then
--     win_opt.title_pos = 'center'
-- end

-- local win = setmetatable({
--     buf       = buf,
--     ns        = ns,
--     height    = win_opt.height,
--     width     = win_opt.width,
--     animation = animation,
--     winid     = api.nvim_open_win(buf.bufnr, enter, win_opt),
-- }, window)

-- return win, win:expand {
--     field = field,
--     target = opts[field],
-- }
