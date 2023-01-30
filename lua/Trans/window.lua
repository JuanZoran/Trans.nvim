local api = vim.api

--- TODO : progress bar
--- char: ■ | □ | ▇ | ▏ ▎ ▍ ▌ ▋ ▊ ▉ █
--- ◖■■■■■■■◗▫◻ ▆ ▆ ▇⃞ ▉⃞

---@diagnostic disable-next-line: duplicate-set-field
function string:width()
    ---@diagnostic disable-next-line: param-type-mismatch
    return vim.fn.strwidth(self)
end

local busy = false
local function check_busy()
    while busy do
        vim.wait(50)
    end
end

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
        return self.winid > 0 and api.nvim_win_is_valid(self.winid)
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
        opts = opts or {}
        local interval = self.animation.interval
        local animation = opts.animation or self.animation.open

        if animation then
            check_busy()

            local handler
            local function wrap(name, target)
                local count = 0
                local action = 'nvim_win_set_' .. target
                return function()
                    if count < self[target] then
                        busy = true
                        count = count + 1
                        api[action](self.winid, count)
                        vim.defer_fn(handler[name], interval)

                    else
                        busy = false
                        if opts.callback then
                            opts.callback()
                        end
                    end
                end
            end

            handler = {
                slid = wrap('slid', 'width'),
                fold = wrap('fold', 'height'),
            }

            handler[animation]()
        end
    end,

    ---安全的关闭窗口
    try_close = function(self, callback)
        if self:is_open() then
            check_busy()
            self.config = api.nvim_win_get_config(self.winid)
            local animation = self.animation
            if animation.close then
                local handler
                local function wrap(name, target)
                    local count = self[target]
                    local action = 'nvim_win_set_' .. target
                    return function()
                        if count > 1 then
                            busy = true
                            count = count - 1
                            api[action](self.winid, count)
                            vim.defer_fn(handler[name], animation.interval)

                        else
                            vim.defer_fn(function()
                                api.nvim_win_close(self.winid, true)
                                self.winid = -1
                                busy = false

                                if type(callback) == 'function' then
                                    callback()
                                end

                            end, animation.interval + 2)
                        end
                    end
                end

                handler = {
                    slid = wrap('slid', 'width'),
                    fold = wrap('fold', 'height'),
                }

                handler[animation.close]()

            else
                api.nvim_win_close(self.winid, true)
                self.winid = -1
            end
        end
    end,

    reopen = function(self, entry, opt, callback)
        check_busy()
        self.config.win = nil
        if opt then
            for k, v in pairs(opt) do
                self.config[k] = v
            end
        end

        self.winid = api.nvim_open_win(self.bufnr, entry, self.config)
        self:open(callback)
    end,

    set_hl = function(self, name, hl)
        api.nvim_set_hl(self.hl, name, hl)
    end
}

---@class window
---@field winid integer 窗口的handle
---@field bufnr integer 窗口对应buffer的handle
---@field width integer 窗口当前的宽度
---@field height integer 窗口当前的高度
---@field hl integer 窗口highlight的namespace
---@field contents table[] 窗口内容的对象数组


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
        relative  = option.relative,
        width     = option.width,
        height    = option.height,
        border    = option.border,
        title     = option.title,
        col       = option.col,
        row       = option.row,

        title_pos = nil,
        focusable = false,
        zindex    = option.zindex or 100,
        style     = 'minimal',
    }

    if opt.title then
        opt.title_pos = 'center'
    end
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
        contents  = setmetatable({}, {
            __index = function(self, key)
                assert(type(key) == 'number')
                self[key] = require('Trans.content')(win)
                return self[key]
            end
        })
    }

    setmetatable(win, { __index = window })
    -- FIXME  :config this
    win:bufset('filetype', 'Trans')
    win:bufset('buftype', 'nofile')

    api.nvim_win_set_hl_ns(win.winid, win.hl)
    win:set_hl('Normal', { link = 'TransWin' })
    win:set_hl('FloatBorder', { link = 'TransBorder' })
    win:set_hl('NormalFloat', { link = 'TransBorder' })
    ---@diagnostic disable-next-line: return-type-mismatch
    return win
end
