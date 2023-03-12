local strategy = {
    play = function(self)
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
    close = function()
        print('TODO: close')
    end,
    toggle_entry = function()
        print('TODO: toggle_entry')
    end,
}



return function(self, action)
    -- TODO :
    strategy[action](self)
end
