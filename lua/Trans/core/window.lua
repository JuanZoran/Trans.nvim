local M    = {}
local api  = vim.api
local conf = require('Trans').conf
local util = require('Trans.util')

M.id    = 0
M.ns    = api.nvim_create_namespace('Trans')
M.bufnr = api.nvim_create_buf(false, true)


function M.init(view)
    vim.validate {
        view = { view, 's' }
    }

    M.view = view
    local is_float = view == 'float'
    M.height = conf.window[view].height
    M.width = conf.window[view].width

    local opts = {
        relative  = is_float and 'editor' or 'cursor',
        width     = M.width,
        height    = M.height,
        style     = 'minimal',
        border    = conf.window.border,
        title     = {
            { '', 'TransTitleRound' },
            { conf.icon.title .. ' Trans', 'TransTitle' },
            { '', 'TransTitleRound' },
        },
        title_pos = 'center',
        focusable = true,
        zindex    = 100,
    }

    if is_float then
        opts.row = math.floor((vim.o.lines - M.height) / 2)
        opts.col = math.floor((vim.o.columns - M.width) / 2)
    else
        opts.row = 2
        opts.col = 2
    end

    M.id = api.nvim_open_win(M.bufnr, is_float, opts)
end

M.draw = function(content)
    api.nvim_buf_set_option(M.bufnr, 'modifiable', true)

    api.nvim_buf_set_lines(M.bufnr, 0, -1, false, content.lines)
    if content.highlights then
        for l, _hl in pairs(content.highlights) do
            for _, hl in ipairs(_hl) do
                api.nvim_buf_add_highlight(M.bufnr, M.ns, hl.name, l - 1, hl._start, hl._end) -- zero index
            end
        end
    end
    M.load_opts()
end


M.load_opts = function()
    api.nvim_buf_set_option(M.bufnr, 'modifiable', false)
    api.nvim_buf_set_option(M.bufnr, 'filetype', 'Trans')
    api.nvim_win_set_option(M.id, 'winhl', 'Normal:TransWin,FloatBorder:TransBorder')
    M['load_' .. M.view .. '_opts']()

end


M.load_hover_opts = function()
    local keymap = conf.keymap[M.view]
    local action = require('Trans.core.action')

    for act, key in pairs(keymap) do
        vim.keymap.set('n', key, action[act])
    end

    api.nvim_create_autocmd(
        { 'InsertEnter', 'CursorMoved', 'BufLeave', }, {
        buffer = 0,
        once = true,
        callback = M.close,
    })
    api.nvim_win_set_option(M.id, 'wrap', M.view ~= 'float')

    local height = util.get_height(M.bufnr, M.id)
    if M.height > height then
        api.nvim_win_set_height(M.id, height)
        M.height = height
    end
end


M.load_float_opts = function()
    vim.keymap.set('n', 'q', function()
        if api.nvim_win_is_valid(M.id) then
            api.nvim_win_close(M.id, true)
        end
    end, { buffer = M.bufnr, silent = true })

    vim.keymap.set('n', '<Esc>', function()
        if api.nvim_win_is_valid(M.id) then
            api.nvim_win_close(M.id, true)
        end
    end, { buffer = M.bufnr, silent = true })
end




M.close = function()
    if api.nvim_win_is_valid(M.id) then
        if conf.window.animation then
            local function narrow()
                if M.height > 1 then
                    M.height = M.height - 1
                    api.nvim_win_set_height(M.id, M.height)
                    vim.defer_fn(narrow, 13)
                else
                    -- Wait animation done
                    vim.defer_fn(function ()
                        api.nvim_win_close(M.id, true)
                    end, 10)
                end
            end
            vim.defer_fn(narrow, 10)

        else
            api.nvim_win_close(M.id, true)
        end
    end
end

M.show = function()
    M.init(M.view or 'float')
    M.load_opts()
end


return M
