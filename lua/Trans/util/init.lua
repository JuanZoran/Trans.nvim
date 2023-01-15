local function get_height(bufnr, winid)
    if not vim.wo[winid].wrap then
        return vim.api.nvim_buf_line_count(bufnr)
    end

    local width = vim.api.nvim_win_get_width(winid)

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local height = 0
    for i = 1, #lines do
        height = height + math.max(1, (math.ceil(vim.fn.strwidth(lines[i]) / width)))
    end
    return height
end

return {
    get_height = get_height,
}
