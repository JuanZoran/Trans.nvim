local spinner = require 'Trans.style.spinner'

local icons = {
    list        = '●',
    star        = '',
    notfound    = ' ',
    yes         = '✔',
    no          = '',
    cell        = '■',
    web         = '󰖟',
    tag         = '',
    pos         = '',
    exchange    = '',
    definition  = '󰗊',
    translation = '󰊿',
}

return {
    spinner = spinner,
    icons = icons,
    progress = {
        width = 40,
        height = 4,
        border = 'rounded',
        padding = 10,
        spinner = 'dots',
        icon = icons,
    },
    hover = {
        spinner = 'dots',
        icon = icons,
    },
}
