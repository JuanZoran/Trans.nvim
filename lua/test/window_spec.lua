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
            for field, values in pairs {
                width = {
                    10,
                    6,
                    8,
                    5,
                },
                height = {
                    10,
                    6,
                    3,
                },
            } do
                for _, value in ipairs(values) do
                    window:smooth_expand { field = field, to = value }
                    assert.are.same(value, window[field](window))
                end
            end
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

    it('adjust_height() can auto adjust window height to buffer display height', function()
        for idx, content in ipairs {
            'cool',
            'co10',
            '家👍',
            '👍ol',
            'cあl',
            '家野',
        } do
            buffer[idx] = content
        end

        local max_height = vim.o.lines - 2
        for width, expect in ipairs {
            [2] = 12,
            [3] = 12,
            [4] = 6,
            [5] = 6,
        } do
            window:smooth_expand { field = 'width', to = width }
            window:adjust_height()
            assert.are.same(math.min(expect, max_height), window:height())
        end
    end)
end))
