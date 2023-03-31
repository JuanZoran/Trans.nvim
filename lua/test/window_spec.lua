require 'test.setup'


describe('window', with_buffer(function(buffer)
    local window
    before_each(function()
        buffer:wipe()
        window = Trans.window.new {
            buffer = buffer,
            win_opts = {
                col = 1,
                row = 1,
                width = 1,
                height = 1,
                relative = 'editor',
            },
        }
        window:set('wrap', false)
    end)

    after_each(function()
        window:try_close()
    end)

    it('can work well when no pass animation table', function()
        window:open()
        assert.is_true(api.nvim_win_is_valid(window.winid))
    end)

    describe('smooth_expand', function()
        it('can work well when no pass animation table', function()
            window:smooth_expand { field = 'width', to = 10 }
            assert.are.same(window:width(), 10)

            window:smooth_expand { field = 'width', to = 6 }
            assert.are.same(window:width(), 6)

            window:smooth_expand { field = 'height', to = 10 }
            assert.are.same(window:height(), 10)

            window:smooth_expand { field = 'height', to = 6 }
            assert.are.same(window:height(), 6)

            window:smooth_expand { field = 'height', to = 6 }
            assert.are.same(window:height(), 6)
        end)

        it("don't change window wrap option", function()
            window:smooth_expand { field = 'width', to = 10 }
            assert.is_false(window:option 'wrap')


            window:set('wrap', true)
            window:smooth_expand { field = 'width', to = 10 }
            assert.is_true(window:option 'wrap')

            window:smooth_expand { field = 'height', to = 10 }
            assert.is_true(window:option 'wrap')
        end)
    end)

    it("resize() don't change window wrap option", function()
        window:resize { width = 10, height = 10 }
        assert.is_false(window:option 'wrap')


        window:set('wrap', true)
        window:resize { width = 5, height = 5 }
        assert.is_true(window:option 'wrap')
    end)
end))
