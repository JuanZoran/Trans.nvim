require 'test.setup'

local Trans = require 'Trans'
local fn = vim.fn
local uv = vim.loop

describe('offline backend', function()
    local tmp_dir
    local backend
    local original_dir
    local original_separator
    local original_system

    local function prepare_backend()
        tmp_dir = fn.tempname()
        fn.mkdir(tmp_dir, 'p')
        Trans.conf = Trans.conf or {}
        original_dir = Trans.conf.dir
        Trans.conf.dir = tmp_dir
        original_separator = Trans.separator
        Trans.separator = '/'

        Trans.conf.offline = {
            filename = 'ultimate.db',
            db_name = 'stardict',
        }

        local db_path = tmp_dir .. '/ultimate.db'
        fn.writefile({ '' }, db_path)

        original_system = fn.system
        fn.system = function(cmd)
            vim.v.shell_error = 0
            return table.concat({
                'theme',
                '\x1f',
                'θiːm',
                '\x1f',
                'n. a subject',
                '\nadj. shimmering soft',
                '\x1f',
                '主题',
                '\n主旋律',
                '\x1f',
                'n/100',
                '\x1f',
                'B',
                '\x1f',
                'Oxford 3000',
                '\x1f',
                'gk cet6',
                '\x1f',
                's/themes',
            })
        end

        package.loaded['Trans.backend.offline'] = nil
        backend = require 'Trans.backend.offline'
    end

    after_each(function()
        if original_system then
            fn.system = original_system
        end
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

    it('formats query results via sqlite CLI', function()
        prepare_backend()

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
