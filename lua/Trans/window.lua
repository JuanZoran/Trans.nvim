local api = vim.api
local display = require('Trans.util.display')

local window = {
    set_buf = function(self, buf)
        api.nvim_win_set_buf(self.winid, buf)
    end,

    is_valid = function(self)
        return api.nvim_win_is_valid(self.winid)
    end,

    set = function(self, option, value)
        api.nvim_win_set_option(self.winid, option, value)
    end,

    option = function(self, name)
        return api.nvim_win_get_option(self.winid, name)
    end,

    set_height = function(self, height)
        api.nvim_win_set_height(self.winid, height)
        self.height = height
    end,

    set_width = function(self, width)
        api.nvim_win_set_width(self.winid, width)
        self.width = width
    end,

    expand = function(self, opts)
        self:lock()
        local field  = opts.field
        local target = opts.target
        local cur    = self[field]
        local times  = math.abs(target - cur)

        local wrap = self:option('wrap')
        self:set('wrap', false)
        local interval = opts.interval or self.animation.interval
        local method = 'set_' .. field

        local frame = target > cur and function(_, cur_times)
            self[method](self, cur + cur_times)
        end or function(_, cur_times)
            self[method](self, cur - cur_times)
        end

        local run = display {
            times    = times,
            frame    = frame,
            interval = interval,
        }

        run(function()
            self:set('wrap', wrap)
            self:unlock()
        end)
        return run
    end,

    try_close = function(self)
        if self:is_valid() then
            local winid = self.winid
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
                api.nvim_win_close(winid, true)
            end)
            return run
        end
    end,

    lock = function(self)
        while self.busy do
            vim.wait(50)
        end
        self.busy = true

    end,

    unlock = function(self)
        self.busy = false
    end,

    set_hl = function(self, name, opts)
        api.nvim_set_hl(self.ns, name, opts)
    end,

    center = function(self, node)
        local text = node[1]
        local width = text:width()
        local win_width = self.width
        local space = math.max(math.floor((win_width - width) / 2), 0)
        node[1] = (' '):rep(space) .. text
        return node
    end,
}
window.__index = window

---window的构造函数
---@param opts table
---@return table
---@return function
return function(opts)
    assert(type(opts) == 'table')
    local buf       = opts.buf
    local height    = opts.height
    local width     = opts.width
    local col       = opts.col
    local row       = opts.row
    local border    = opts.border
    local title     = opts.title
    local relative  = opts.relative
    local zindex    = opts.zindex or 100
    local enter     = opts.enter
    local ns        = opts.ns
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
