require 'test.setup'

local Trans = require 'Trans'
local fn = vim.fn

describe('offline backend', function()
local backend
local tmp_dir
local dict_stub
local original_separator
local original_dir

    local sample_row = {
        word = 'theme',
        phonetic = 'θiːm',
        collins = 'B',
        oxford = 'Oxford 3000',
        definition = 'n. a subject\nadj. shimmering soft',
        translation = '主题\n主旋律',
        pos = 'n/100',
        tag = 'gk cet6',
        exchange = 's/themes',
    }

    local function prepare_backend()
        tmp_dir = fn.tempname()
        fn.mkdir(tmp_dir, 'p')
        Trans.conf = Trans.conf or {}
        original_dir = Trans.conf.dir
        Trans.conf.dir = tmp_dir
        original_separator = Trans.separator
        Trans.separator = '/'

        dict_stub = {
            select = function(_, _)
                return { vim.deepcopy(sample_row) }
            end,
        }

        package.preload['sqlite.db'] = function()
            return {
                open = function()
                    return dict_stub
                end,
            }
        end

        package.loaded['sqlite.db'] = nil
        package.loaded['Trans.backend.offline'] = nil
        backend = require 'Trans.backend.offline'
    end

    before_each(function()
        prepare_backend()
    end)

    after_each(function()
        package.preload['sqlite.db'] = nil
        package.loaded['sqlite.db'] = nil
        package.loaded['Trans.backend.offline'] = nil
        if original_separator then
            Trans.separator = original_separator
        end
        if original_dir then
            Trans.conf.dir = original_dir
        end
        if tmp_dir and fn.isdirectory(tmp_dir) == 1 then
            fn.delete(tmp_dir, 'rf')
        end
    end)

    it('formats query results', function()
        local data = {
            str = 'theme',
            from = 'en',
            is_word = true,
            result = {},
        }

        backend.query(data)
        local result = data.result.offline
        assert.are.equal('theme', result.title.word)
        assert.are.equal('B', result.title.collins)
        assert.are.equal('Oxford 3000', result.title.oxford)
        assert.are.same({ '主题', '主旋律' }, result.translation)
        assert.are.same({ 'n. a subject', 'adj. shimmering soft' }, result.definition)
        assert.are.equal('themes', result.exchange['复数        '])
        assert.are.same({ '高考', '六级' }, result.tag)
    end)
end)
