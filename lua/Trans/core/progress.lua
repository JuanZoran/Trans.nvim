---@class TransProgressOpts
---@field width integer
---@field height integer
---@field row integer
---@field col integer
---@field zindex integer
---@field border string
---@field message string
---@field animation table?
---@field life integer

local Trans = require 'Trans'
local buffer = Trans.buffer
local window = Trans.window
local ui = Trans.style.ui
local spinners = ui.spinner
local uv = vim.loop
local progress_util = require 'Trans.core.progress_util'

---@class TransProgress
---@field buffer TransBuffer
---@field window TransWindow
---@field opts TransProgressOpts
---@field bar_width integer
---@field closed boolean
---@field message string
local M = {}
M.__index = M

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function layout(opts)
    local columns = vim.o.columns
    local width = clamp(opts.width, 20, math.max(columns - 4, 20))
    local col = opts.col or math.max(columns - width - 2, 0)
    return width, col
end

local progress_theme = ui.progress
local default_opts = {
    width = progress_theme.width,
    height = progress_theme.height,
    row = 1,
    col = nil,
    zindex = 300,
    border = progress_theme.border,
    message = 'Downloading dictionary...',
    life = 1200,
    spinner = progress_theme.spinner,
    interval = 80,
}

---@param opts TransProgressOpts?
---@return TransProgress
function M.new(opts)
    opts = vim.tbl_deep_extend('force', default_opts, opts or {})
    local width, col = layout(opts)
    local buf = buffer.new()
    local win = window.new {
        buffer = buf,
        win_opts = {
            relative = 'editor',
            width = width,
            height = opts.height,
            row = opts.row,
            col = col,
            border = opts.border,
            style = 'minimal',
            focusable = false,
            noautocmd = true,
            zindex = opts.zindex,
        },
        enter = false,
        animation = opts.animation,
    }

    local self = setmetatable({
        buffer = buf,
        window = win,
        opts = opts,
        bar_width = math.max(6, width - 8),
        message = opts.message,
        closed = false,
        percent = 0,
        spinner = spinners[opts.spinner] or spinners.dots,
        spinner_index = 1,
        detail = '',
        downloaded = 0,
        total = 0,
    }, M)

    if uv and uv.new_timer then
        self.spin_timer = uv.new_timer()
        self.spin_timer:start(0, opts.interval, vim.schedule_wrap(function()
            if self.closed then
                self:stop_timer()
                return
            end

            self.spinner_index = (self.spinner_index % #self.spinner) + 1
            self:update({ percent = self.percent }, true)
        end))
    end

    self:update(0)
    return self
end

---@param opts? table|number
---@param skip_anim boolean?
function M:update(opts, skip_anim)
    if self.closed or not self.window or not self.window:is_valid() then
        return
    end

    if type(opts) ~= 'table' then
        opts = { percent = opts }
    end
    local has_percent = opts.percent ~= nil
    local computed_percent = opts.percent
    if not has_percent and opts.downloaded and opts.total then
        computed_percent = progress_util.percent(opts.downloaded, opts.total)
        has_percent = computed_percent ~= nil
    end

    local percent = clamp(math.floor((has_percent and computed_percent or self.percent or 0)), 0, 100)
    if has_percent then
        self.percent = percent
    end
    self.message = opts.message or self.message or self.opts.message
    if opts.downloaded ~= nil then
        self.downloaded = opts.downloaded
    end
    if opts.total ~= nil then
        self.total = opts.total
    end
    local bar_width = self.bar_width
    local filled = math.floor(bar_width * percent / 100)
    local bar = string.rep('█', filled) .. string.rep(' ', bar_width - filled)
    local detail_line = ''
    if self.downloaded and self.downloaded > 0 then
        detail_line = progress_util.format_size(self.downloaded)
    end
    if self.total and self.total > 0 then
        local total_line =
            detail_line == '' and progress_util.format_size(self.total)
                or detail_line .. ' / ' .. progress_util.format_size(self.total)
        detail_line = total_line
    end
    self.detail = detail_line
    local spinner_char = self.spinner[self.spinner_index] or self.spinner[1]
    local progress_line
    if has_percent then
        progress_line = string.format('%s [%s] %3d%%', spinner_char, bar, percent)
    else
        progress_line = string.format('%s %s', spinner_char, detail_line ~= '' and detail_line or '下载中...')
    end

    self.buffer:wipe()
    self.buffer:setline(self.message, 1)
    self.buffer:setline(progress_line, 2)
    self.buffer:setline(detail_line, 3)
    self.buffer:add_highlight(2, 'TransWaitting', 0, -1)

    if not skip_anim then
        self.spinner_index = (self.spinner_index % #self.spinner) + 1
    end
end

---@param success boolean
---@param info string|table?
function M:finish(success, info)
    if self.closed then
        return
    end

    local opts = type(info) == 'table' and info or { message = info }
    if self.total and self.total > 0 then
        opts.percent = opts.percent or (success and 100 or 0)
    else
        opts.percent = nil
    end
    opts.message = opts.message or (success and 'Download completed' or 'Download failed')
    self:update(opts, true)
    self.closed = true
    self:stop_timer()
    vim.defer_fn(function()
        if self.window and self.window:is_valid() then
            self.window:try_close()
        end
        if self.buffer and self.buffer:is_valid() then
            self.buffer:destroy()
        end
    end, self.opts.life)
end

---@param message string?
function M:set_message(message)
    self.message = message or self.message
end

function M:stop_timer()
    if self.spin_timer then
        self.spin_timer:stop()
        self.spin_timer:close()
        self.spin_timer = nil
    end
end

return M
