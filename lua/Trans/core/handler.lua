local icon = require('Trans').conf.icon

-- local components = {
--     'title',
--     'tag',
--     'pos',
--     'exchange',
--     'translation',
--     'definition'
-- }

local tag_map = {
    zk    = '中考',
    gk    = '高考',
    ky    = '考研',
    cet4  = '四级',
    cet6  = '六级',
    ielts = '雅思',
    toefl = '托福',
    gre   = 'gre ',
}
local pos_map = {
    a = '代词pron        ',
    c = '连接词conj      ',
    i = '介词prep        ',
    j = '形容词adj       ',
    m = '数词num         ',
    n = '名词n           ',
    p = '代词pron        ',
    r = '副词adv         ',
    u = '感叹词int       ',
    v = '动词v           ',
    x = '否定标记not     ',
    t = '不定式标记infm  ',
    d = '限定词determiner',
}


local exchange_map = {
    ['p'] = '过去式      ',
    ['d'] = '过去分词    ',
    ['i'] = '现在分词    ',
    ['r'] = '比较级      ',
    ['t'] = '最高级      ',
    ['s'] = '复数        ',
    ['0'] = '原型        ',
    ['1'] = '类别        ',
    ['3'] = '第三人称单数',
    -- ['f'] = '第三人称单数',
}

local function exist(res)
    return res and res ~= ''
end

M = {
    title = function(result, content)
        local line = content:alloc_newline()
        line.add_item(result.word, 'TransWord')
        local pho = ('[' .. (exist(result.phonetic) and result.phonetic or icon.notfound) .. ']')
        -- line.add_item(pho, 'TransPhonetic', #pho)
        line.add_item(pho, 'TransPhonetic')
        line.add_item((exist(result.collins) and icon.star:rep(result.collins) or icon.notfound))
        line.add_item((exist(result.oxford) and icon.yes or icon.no))
        line.load_line()
    end,

    tag = function(result, content)
        if exist(result.tag) then
            content:addline('标签:', 'TransRef')
            local tags = vim.tbl_map(function(tag)
                return tag_map[tag]
            end, vim.split(result.tag, ' ', { plain = true, trimempry = true }))

            local size = #tags
            local i = 1
            while i <= size do
                content:addline('    ' .. tags[i] .. '    ' .. (tags[i + 1] or '') .. '    ' .. (tags[i + 2] or ''),
                    'TransTag')
                i = i + 3
            end
            content:addline('')
        end
    end,

    pos = function(result, content)
        if exist(result.pos) then
            content:addline('词性:', 'TransRef')
            vim.tbl_map(function(pos)
                content:addline('    ' .. pos_map[pos:sub(1, 1)] .. pos:sub(3) .. '%', 'TransPos')
            end, vim.split(result.pos, '/', { plain = true, trimempry = true }))

            content:addline('')
        end
    end,

    exchange = function(result, content)
        if exist(result.exchange) then
            content:addline('词性变化:', 'TransRef')
            vim.tbl_map(function(exc)
                content:addline('    ' .. exchange_map[exc:sub(1, 1)] .. '    ' .. exc:sub(3), 'TransExchange')
                -- content:addline('    ' .. exchange_map[exc:sub(1, 1)] .. exc:sub(2), 'TransExchange')
            end, vim.split(result.exchange, '/', { plain = true, trimempry = true }))

            content:addline('')
        end
    end,

    translation = function(result, content)
        if result.translation and result.translation ~= '' then
            local ref = {
                { '中文翻译:', 'TransRef' }
            }

            local translations = {
                highlight = 'TransTranslation',
                indent = 4,
                emptyline = true,
            }
            for trans in vim.gsplit(result.translation, '\n', true) do
                table.insert(translations, trans)
            end

            return { ref, translations }
        end
    end,


    definition = function(result, content)
        if result.definition and result.definition ~= '' then
            local ref = {
                { '英文注释:', 'TransRef' }
            }

            local definitions = {
                highlight = 'TransDefinition',
                indent = 4,
                emptyline = true,
            }

            for defin in vim.gsplit(result.definition, '\n', true) do
                if defin ~= '' then
                    table.insert(definitions, defin)
                end
            end

            return { ref, definitions }
        end
    end
}

return M
