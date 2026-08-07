---@diagnostic disable: param-type-mismatch
require 'test.setup'

local util = Trans.util

describe('util.display_height', function()
    it('can calculate the height of lines when window with wrap option', function()
        local lines = {
            '1234567890',
            '1234567890',
            '1234567890',
            '1234567890',
            '1234567890',
            '1234567890',
            '1234567890',
            '1234567890',
            '1234567890',
        }

        assert.are.equal(#lines, util.display_height(lines, 10))
        assert.are.equal(#lines, util.display_height(lines, 11))
        assert.are.equal(2 * #lines, util.display_height(lines, 9))

        -- Unicode width test
        local u_lines = {
            '12345678👍', -- 10
            'あうえお', -- 8
            '𠮷野い𠮷家野家家', -- 16
            '👍👍👍お家', -- 10
        }

        assert.are.equal(4, util.display_height(u_lines, 20))
        assert.are.equal(4, util.display_height(u_lines, 16))
        assert.are.equal(5, util.display_height(u_lines, 10))
        assert.are.equal(7, util.display_height(u_lines, 8))
        assert.are.equal(9, util.display_height(u_lines, 7))
    end)
end)

describe('util.display_width', function()
    it('can calculate the max width of lines', function()
        local lines = {
            '1234567890',
            '123456789',
            '12345678',
            '1234567',
            '123456',
            '12345',
            '1234',
            '123',
            '12',
            '1',
        }

        assert.are.equal(10, util.display_width(lines))
        -- Unicode width test
        local u_lines = {
            '12345678👍', -- 10
            'あうえお', -- 8
            '𠮷野い𠮷家野家家', -- 16
            '👍👍👍お家', -- 10
        }

        assert.are.equal(16, util.display_width(u_lines))
    end)
end)

describe('util.center', function()
    it('will return the node if its width more than width', function()
        local node = i { '1234567890' }
        assert.are.same(node, util.center(node, 9))
    end)

    it('will auto padding space', function()
        local node = i { '1234567890' }
        assert.are.same(i { (' '):rep(2) .. '1234567890' }, util.center(node, 15))
    end)
end)

describe('util.is_word', function()
    it('can detect word', function()
        for test, value in pairs {
            ['あうえお'] = false,
            ['hello']        = true,
            [' hello']       = false,
            ['hello world']  = false,
            ['test_cool']    = false,
        } do
            assert.are.same(util.is_word(test), value)
        end
    end)
end)

describe('util.replace_chinese_punctuation', function()
    it('replaces Chinese punctuation with English punctuation', function()
        local input = '你好，世界。欢迎！你在这里吗？'
        local expected = '你好,世界.欢迎!你在这里吗?'
        assert.are.equal(expected, util.replace_chinese_punctuation(input))
    end)
end)
