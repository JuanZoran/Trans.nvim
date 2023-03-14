local strategy = {
    play = function()
        print('TODO: play')
    end,
    pageup = function()
        print('TODO: pageup')
    end,
    pagedown = function()
        print('TODO: pagedown')
    end,
    pin = function()
        print('TODO: pin')
    end,
    close = function(hover)
        hover:destroy()
    end,
    toggle_entry = function()
        print('TODO: toggle_entry')
    end,
}


---@class TransHover
---@field execute fun(hover: TransHover, action: string)
return function(hover, action)
    -- TODO :
    strategy[action](hover)
end