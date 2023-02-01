local api = vim.api
local new_content = require('Trans.content')
local new_animation = require('Trans.util.animation')


local busy = false
local function lock()
    while busy do
        vim.wait(50)
    end
    busy = true
end

---@class window
---@field winid integer 窗口的handle
---@field bufnr integer 窗口对应buffer的handle
---@field width integer 窗口当前的宽度
---@field height integer 窗口当前的高度
---@field hl integer 窗口highlight的namespace
---@field contents table[] 窗口内容的对象数组

---@type window
local window = {
    set = function(self, option, value)
        api.nvim_win_set_option(self.winid, option, value)
    end,

    set_height = function(self, height)
        api.nvim_win_set_height(self.winid, height)
        self.height = height
    end,

    set_width = function(self, width)
        api.nvim_win_set_width(self.winid, width)
        self.width = width
    end,

    bufset = function(self, option, value)
        api.nvim_buf_set_option(self.bufnr, option, value)
    end,

    ---@nodiscard
    option = function(self, name)
        return api.nvim_win_get_option(self.winid, name)
    end,

    map = function(self, key, operation)
        vim.keymap.set('n', key, operation, {
            buffer = self.bufnr,
            silent = true,
        })
    end,

    ---@nodiscard
    is_open = function(self)
        return api.nvim_win_is_valid(self.winid)
    end,

    normal = function(self, key)
        api.nvim_buf_call(self.bufnr, function()
            vim.cmd([[normal! ]] .. key)
        end)
    end,

    draw = function(self)
        local offset = 0
        for _, content in ipairs(self.contents) do
            content:attach(offset)
            offset = offset + content.size
        end
    end,

    open = function(self, opts)
        self:draw()
        local wrap = self:option('wrap')
        self:set('wrap', false)
        opts            = opts or {}
        local animation = opts.animation or self.animation.open
        local callback  = function()
            busy = false
            self:set('wrap', wrap)
            if opts.callback then
                opts.callback()
            end
        end

        lock()
        if animation then
            local interval = self.animation.interval
            local field = ({
                fold = 'height',
                slid = 'width',
            })[animation]

            local method = api['nvim_win_set_' .. field]
            local winid = self.winid
            new_animation({
                interval = interval,
                times = self[field],
                frame = function(_, times)
                    method(winid, times)
                end,
                callback = callback,
            }):display()

        else
            callback()
        end
    end,

    ---安全的关闭窗口
    try_close = function(self, opts)
        opts = opts or {}
        self:set('wrap', false)

        if self:is_open() then
            local callback = function()
                api.nvim_win_close(self.winid, true)
                self.winid = -1
                busy = false
                if opts.callback then
                    opts.callback()
                end
                if api.nvim_buf_is_valid(self.bufnr) and opts.wipeout then
                    api.nvim_buf_delete(self.bufnr, { force = true })
                    self.bufnr = -1
                end
            end

            lock()
            self.config = api.nvim_win_get_config(self.winid)
            local animation = self.animation.close
            if animation then
                local interval = self.animation.interval
                local field = ({
                    fold = 'height',
                    slid = 'width',
                })[animation]

                local target = self[field]
                local method = api['nvim_win_set_' .. field]
                local winid = self.winid
                new_animation({
                    times = target,
                    frame = function(_, times)
                        method(winid, target - times)
                    end,
                    callback = callback,
                    interval = interval,
                }):display()

            else
                callback()
            end
        end
    end,

    reopen = function(self, opts)
        assert(self.bufnr ~= -1)
        local entry   = opts.entry or false
        local win_opt = opts.win_opt or {}
        local opt     = opts.opt

        self.config.win = nil
        for k, v in pairs(win_opt) do
            self.config[k] = v
        end

        self.winid = api.nvim_open_win(self.bufnr, entry, self.config)
        self:open(opt)
    end,

    set_hl = function(self, name, opts)
        api.nvim_set_hl(self.hl, name, opts)
    end,

    new_content = function(self)
        local index = self.size + 1
        self.size = index
        self.contents[index] = new_content(self)

        return self.contents[index]
    end,
}

window.__index = window



---窗口对象的构造器
---@param entry boolean 光标初始化时是否应该进入窗口
---@param option table 需要设置的选项
---@return window win
---@nodiscard
return function(entry, option)
    vim.validate {
        entry = { entry, 'b' },
        option = { option, 't' },
    }

    local opt = {
        relative = option.relative,
        width    = option.width,
        height   = option.height,
        border   = option.border,
        title    = option.title,
        col      = option.col,
        row      = option.row,

        title_pos = nil,
        focusable = false,
        zindex    = option.zindex or 100,
        style     = 'minimal',
    }

    if opt.title then
        opt.title_pos = 'center'
    end

    local bufnr = api.nvim_create_buf(false, true)
    local ok, winid = pcall(api.nvim_open_win, bufnr, entry, opt)
    if not ok then
        error('open window faild: ' .. vim.inspect(opt))
    end

    local win
    win = {
        winid     = winid,
        bufnr     = bufnr,
        width     = opt.width,
        height    = opt.height,
        animation = option.animation,
        hl        = api.nvim_create_namespace('TransWinHl'),
        size      = 0,
        contents  = {}
    }

    ---@diagnostic disable-next-line: param-type-mismatch
    setmetatable(win, window)


    win:bufset('filetype', 'Trans')
    win:bufset('buftype', 'nofile')
    api.nvim_win_set_hl_ns(win.winid, win.hl)
    win:set_hl('Normal', { link = 'TransWin' })
    win:set_hl('FloatBorder', { link = 'TransBorder' })
    ---@diagnostic disable-next-line: return-type-mismatch
    return win
end
