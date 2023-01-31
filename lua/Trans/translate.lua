local function get_select()
    local s_start = vim.fn.getpos("v")
    local s_end = vim.fn.getpos(".")
    if s_start[2] > s_end[2] or s_start[3] > s_end[3] then
        s_start, s_end = s_end, s_start
    end

    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return table.concat(lines, '')
end

local function get_word(mode)
    local word
    if mode == 'n' then
        word = vim.fn.expand('<cword>')
    elseif mode == 'v' then
        vim.api.nvim_input('<ESC>')
        word = get_select()
    elseif mode == 'i' then
        -- TODO Use Telescope with fuzzy finder
        vim.ui.input({ prompt = '请输入需要查询的单词: ' }, function(input)
            word = input
        end)
    else
        error('invalid mode: ' .. mode)
    end

    return word
end

return function(mode, view)
    vim.validate {
        mode = { mode, 's', true },
        view = { view, 's', true }
    }

    mode = mode or vim.api.nvim_get_mode().mode
    view = view or require('Trans').conf.view[mode]
    assert(mode and view)
    local word = get_word(mode)
    if word == nil or word == '' then
        return
    else
        require('Trans.view.' .. view)(word:gsub('^%s+', '', 1))
    end
end
