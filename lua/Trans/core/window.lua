local M    = {}
local api  = vim.api
local conf = require('Trans').conf
local action = require('Trans.core.action')

M.id       = 0
M.bufnr    = 0
M.ns       = api.nvim_create_namespace('Trans')


function M.init(view)
    vim.validate {
        view = { view, 's' }
    }

    M.view = view
    M.float = view == 'float'
    M.height = conf.window[view].height
    M.width = conf.window[view].width

    local opts = {
        relative  = M.float and 'editor' or 'cursor',
        width     = M.width,
        height    = M.height,
        style     = 'minimal',
        border    = conf.window.border,
        title     = {
            {'', 'TransTitleRound'},
            {'Trans', 'TransTitle'},
            {'', 'TransTitleRound'},
        },
        title_pos = 'center',
        focusable = true,
        zindex    = 100,
    }

    if M.float then
        opts.row = math.floor((vim.o.lines - M.height) / 2)
        opts.col = math.floor((vim.o.columns - M.width) / 2)
    else
        opts.row = 2
        opts.col = 2
    end

    M.bufnr = api.nvim_create_buf(false, true)
    M.id = api.nvim_open_win(M.bufnr, M.float, opts)
end

M.draw = function(content)
    api.nvim_buf_set_lines(M.bufnr, 0, -1, false, content.lines)

    if content.highlights then
        for l, _hl in pairs(content.highlights) do
            for _, hl in ipairs(_hl) do
                api.nvim_buf_add_highlight(M.bufnr, M.ns, hl.name, l - 1, hl._start, hl._end) -- zero index
            end
        end
    end

    local len = #content.lines
    if M.height > len then
        api.nvim_win_set_height(M.id, len)
    end
    if len == 1 then
        api.nvim_win_set_width(M.id, content.get_width(content.lines[1]))
    end


    api.nvim_buf_set_option(M.bufnr, 'modifiable', false)
    api.nvim_buf_set_option(M.bufnr, 'filetype', 'Trans')
    api.nvim_win_set_option(M.id, 'wrap', not M.float)
    api.nvim_win_set_option(M.id, 'winhl', ('Normal:Trans%sWin,FloatBorder:Trans%sBorder'):format(M.view, M.view))

    if M.float then
        vim.keymap.set('n', 'q', function()
            if api.nvim_win_is_valid(M.id) then
                api.nvim_win_close(M.id, true)
            end
        end, { buffer = M.bufnr, silent = true })

    else
        -- TODO : set keymaps for window
        M.auto_close()
    end
end


M.auto_close = function()
    api.nvim_create_autocmd(
        { 'InsertEnter', 'CursorMoved', 'BufLeave', }, {
        buffer = 0,
        once = true,
        callback = function()
            if api.nvim_win_is_valid(M.id) then
                api.nvim_win_close(M.id, true)
            end
        end,
    })

end


-- M.load_keymap = function (once)
--     local keymap = conf.keymap[M.view]
--     local function warp(func)
--         return func or function ()
--             vim.api.nvim_get_keymap(' th')
--         end
--     end
--
-- end


return M
