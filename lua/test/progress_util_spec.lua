require 'test.setup'

local progress_util = require 'Trans.core.progress_util'

describe('progress_util', function()
    it('formats bytes with units', function()
        assert.are.equal('0B', progress_util.format_size(0))
        assert.are.equal('1.0K', progress_util.format_size(1024))
        assert.are.equal('1.5M', progress_util.format_size(1.5 * 1024 * 1024))
        assert.are.equal('2.0G', progress_util.format_size(2 * 1024 * 1024 * 1024))
    end)

    it('calculates percent when total is valid', function()
        assert.are.equal(50, progress_util.percent(512, 1024))
        assert.are.equal(100, progress_util.percent(2048, 1024))
        assert.are.equal(0, progress_util.percent(0, 1024))
    end)

    it('returns nil percent when total is missing or invalid', function()
        assert.is_nil(progress_util.percent(nil, 1024))
        assert.is_nil(progress_util.percent(100, 0))
        assert.is_nil(progress_util.percent(100, nil))
    end)
end)
