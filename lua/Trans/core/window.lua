local api = vim.api
local Trans = require("Trans")

---@class TransWindow
local window = {}

---Change window attached buffer
---@param buf TransBuffer
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
---@param name string option name
---@param value any
function window:set(name, value)
    if self:is_valid() then
        api.nvim_win_set_option(self.winid, name, value)
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
---@return integer
function window:width()
    return api.nvim_win_get_width(self.winid)
end

---Get window height
---@return integer
function window:height()
    return api.nvim_win_get_height(self.winid)
end

-- TODO :
-- function window:adjust()

-- end

---Expand window [width | height] value
---@param opts
---|{ field: string, to: integer}
function window:smooth_expand(opts)
    local field = opts.field -- width | height
    local from  = api['nvim_win_get_' .. field](self.winid)
    local to    = opts.to

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

---Resize window
---@param opts
---|{ width: integer, height: integer }
function window:resize(opts)
    local width = opts[1]
    local height = opts[2]


    if self:width() ~= width then
        self:smooth_expand {
            field = 'width',
            to = width
        }
    end


    if self:height() ~= height then
        self:smooth_expand {
            field = 'height',
            to = height
        }
    end
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
            to = 1,
        })
    end

    api.nvim_win_close(self.winid, true)
end

---Set window local highlight group
---@param name string
---@param opts table highlight config
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
            to = to,
        })
    else
        self.winid = api.nvim_open_win(self.buffer.bufnr, self.enter, win_opts)
    end
end

-- function window:center(node)
--     -- TODO :
--     print('TODO Center')
--     -- local text = node[1]
--     -- local width = text:width()
--     -- local win_width = self.width
--     -- local space = math.max(math.floor((win_width - width) / 2), 0)
--     -- node[1] = (' '):rep(space) .. text
--     -- return node
-- end

window.__index = window


---@alias WindowOpts
---|{style: string, border: string, focusable: boolean, noautocmd?: boolean, relative: string, width: integer, height: integer, col: integer, row: integer, zindex?: integer, title?: table | string}


---@class TransWindowOpts
local default_opts = {
    enter    = false,
    winid    = -1,
    ---@type WindowOpts
    win_opts = {
        style     = 'minimal',
        border    = 'rounded',
        focusable = false,
        noautocmd = true,
    },
}




---@class TransWindow
---@field buffer TransBuffer attached buffer object
---@field win_opts table window config [**When open**]
---@field private winid integer window handle
---@field ns integer namespace for highlight
---@field enter boolean cursor should [enter] window when open
---@field animation
---|{open: string | boolean, close: string | boolean, interval: integer} Hover Window Animation


---Create new window
---@param opts TransWindowOpts window config
---@return TransWindow
function window.new(opts)
    opts = vim.tbl_deep_extend('keep', opts, default_opts)

    local win = setmetatable(opts, window)
    ---@cast win TransWindow

    win:open()
    return win
end

---@class Trans
---@field window TransWindow
return window
-- local win_opt   = {
--     zindex    = zindex,
--     width     = width,
--     height    = height,
--     col       = col,
--     row       = row,
--     border    = border,
--     title     = title,
--     relative  = relative,
-- }