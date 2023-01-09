local type_check = require("Trans.util.debug").type_check


local function format(items, interval)

end


local function process (opts)
    type_check {
        opts = { opts, 'table' },
        ['opts.field']  = { opts.field, 'table'  },
        ['opts.order']  = { opts.order, 'table'  },
        ['opts.win']    = { opts.win, 'table'    },
        ['opts.engine'] = { opts.engine, 'table' },
    }

    local content = require('Trans.component.content'):new()

    for _, v in ipairs(opts.order) do
        local items = format(require("Trans.component." .. opts.engine .. '.' .. v), 4)
        content:insert(items)
    end

    local lines, __highlight = content:data()
    vim.api.nvim_buf_set_lines(opts.bufnr, 0, lines)

    for line, l_hl in ipairs(__highlight) do
        for _, hl in ipairs(l_hl) do
            vim.api.nvim_buf_add_highlight(opts.bufnr, line, hl.name, hl._start, hl._end)
        end
    end
end


return process
