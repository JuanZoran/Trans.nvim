local api = vim.api
local new_content = require('Trans.content')

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
        opts            = opts or {}
        local interval  = self.animation.interval
        local animation = opts.animation or self.animation.open
        local callback  = opts.callback

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
                        if callback then
                            callback()
                        end
                    end
                end
            end

            handler = {
                slid = wrap('slid', 'width'),
                fold = wrap('fold', 'height'),
            }

            handler[animation]()

        elseif callback then
            callback()
        end
    end,

    ---安全的关闭窗口
    try_close = function(self, opts)
        opts = opts or {}
        local callback = opts.callback
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

    reopen = function(self, opts)
        local entry    = opts.entry or false
        local win_opt  = opts.win_opt
        local opt      = opts.opt

        check_busy()
        self.config.win = nil
        if win_opt then
            for k, v in pairs(win_opt) do
                self.config[k] = v
            end
        end

        self.winid = api.nvim_open_win(self.bufnr, entry, self.config)
        self:open(opt)
    end,

    set_hl = function(self, name, hl)
        api.nvim_set_hl(self.hl, name, hl)
    end,

    new_content = function(self)
        local index = self.size + 1
        self.size = index + 1
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
    win:set_hl('NormalFloat', { link = 'TransBorder' })
    ---@diagnostic disable-next-line: return-type-mismatch
    return win
end
