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



return function(hover, action)
    -- TODO :
    coroutine.wrap(strategy[action])(hover)
end
