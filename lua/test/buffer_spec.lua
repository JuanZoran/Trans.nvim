require 'test.setup'

describe('buffer:setline()', function()
    it('can accept one index linenr as second arg', with_buffer(function(buffer)
        buffer:setline({
            i { 'hello ' },
            i { 'world' },
        }, 1)
        assert.are.equal(buffer[1], 'hello world')
    end))

    it('will append line when no second arg passed', with_buffer(function(buffer)
        buffer[1] = 'hello'
        buffer:setline 'world'

        assert.are.equal(buffer[2], 'world')
    end))

    describe('and buffer[i]', function()
        it('can accept a string as first arg', with_buffer(function(buffer)
            buffer:setline 'hello world'
            buffer[2] = 'hello world'
            assert.are.equal(buffer[1], 'hello world')
            assert.are.equal(buffer[2], 'hello world')
        end))

        it('can accept a node as first arg', with_buffer(function(buffer)
            buffer:setline(i { 'hello world' })
            buffer[2] = i { 'hello world' }
            assert.are.equal(buffer[1], 'hello world')
            assert.are.equal(buffer[2], 'hello world')
        end))

        it('can accept a node list as first arg', with_buffer(function(buffer)
            buffer:setline {
                i { 'hello ' },
                i { 'world' },
            }

            buffer[2] = {
                i { 'hello ' },
                i { 'world' },
            }

            assert.are.equal(buffer[1], 'hello world')
            assert.are.equal(buffer[2], 'hello world')
        end))

        it(' will fill with empty line if linenr is more than line_count', with_buffer(function(buffer)
            buffer:setline('hello world', 3)
            buffer[4] = 'hello world'
            assert.are.equal(buffer[1], '')
            assert.are.equal(buffer[2], '')
            assert.are.equal(buffer[3], 'hello world')
            assert.are.equal(buffer[4], 'hello world')

            buffer:wipe()

            buffer[1] = i { 'test' }
            buffer[3] = 'hello world'
            assert.are.equal(buffer[1], 'test')
            assert.are.equal(buffer[2], '')
            assert.are.equal(buffer[3], 'hello world')
        end))
    end)
end)
-- TODO :Add node test

describe('buffer:deleteline()', with_buffer(function(buffer)
    before_each(function()
        buffer:wipe()
    end)

    it('will delete the last line if no arg', function()
        buffer[1] = 'line 1'
        buffer[2] = 'line 2'
        buffer:deleteline()
        assert.are.equal(buffer:line_count(), 1)
        assert.are.equal(buffer[1], 'line 1')

        buffer:deleteline()
        assert.are.equal(buffer:line_count(), 0)
    end)

    it('can accept a one indexed linenr to be deleted', function()
        buffer[1] = 'line 1'
        buffer[2] = 'line 2'
        buffer:deleteline(1)
        assert.are.equal(buffer[1], 'line 2')
    end)

    it('can accept a one indexed range to be deleted', function()
        stub(api, 'nvim_buf_set_lines')
        buffer[1] = 'line 1'
        buffer[2] = 'line 2'
        buffer[3] = 'line 3'
        buffer:deleteline(1, 2)
        ---@diagnostic disable-next-line: param-type-mismatch
        assert.stub(api.nvim_buf_set_lines).called_with(buffer.bufnr, 0, 2, false, {})

        api.nvim_buf_set_lines:revert()
        buffer:deleteline(1, 2)
        assert.are.equal(buffer[1], 'line 3')
    end)
end))


describe('buffer:lines()', with_buffer(function(buffer)
    before_each(function()
        buffer:wipe()
    end)

    it('will return all lines if no arg', function()
        buffer[1] = 'line 1'
        buffer[2] = 'line 2'
        local lines = buffer:lines()
        assert.are.equal(lines[1], 'line 1')
        assert.are.equal(lines[2], 'line 2')
    end)

    it('will return all lines after linenr accept a one indexed linenr', function()
        buffer[1] = 'line 1'
        buffer[2] = 'line 2'
        buffer[3] = 'line 3'
        buffer[4] = 'line 4'
        local lines = buffer:lines(2)
        assert.are.equal(lines[1], 'line 2')
        assert.are.equal(lines[2], 'line 3')
        assert.are.equal(lines[3], 'line 4')
    end)

    it('can accept a one indexed range', function()
        buffer[1] = 'line 1'
        buffer[2] = 'line 2'
        buffer[3] = 'line 3'
        local lines = buffer:lines(1, 2)
        assert.are.equal(lines[1], 'line 1')
        assert.are.equal(lines[2], 'line 2')

        lines = buffer:lines(2, 3)
        assert.are.equal(lines[1], 'line 2')
        assert.are.equal(lines[2], 'line 3')
    end)
end))
