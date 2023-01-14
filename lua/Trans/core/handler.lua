local M = {}
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
    ['f'] = '第三人称单数',
}

local function exist(res)
    return res and res ~= ''
end

local function expl(c, text)
    local wrapper = c:text_wrapper()
    wrapper('', 'TransTitleRound')
    wrapper(text, 'TransTitle')
    wrapper('', 'TransTitleRound')
end

local indent = '    '

M.hover = {
    title = function(result, content)
        local line = content:alloc_items()
        line.add_item(result.word, 'TransWord')
        local pho = ('[' .. (exist(result.phonetic) and result.phonetic or icon.notfound) .. ']')
        -- line.add_item(pho, 'TransPhonetic', #pho)
        line.add_item(pho, 'TransPhonetic')
        line.add_item((exist(result.collins) and icon.star:rep(result.collins) or icon.notfound), 'TransCollins')
        line.add_item((result.oxford == 1 and icon.yes or icon.no))
        line.load()
    end,

    tag = function(result, content)
        if exist(result.tag) then
            expl(content, '标签')

            local tags = vim.tbl_map(function(tag)
                return tag_map[tag]
            end, vim.split(result.tag, ' ', { plain = true, trimempry = true }))

            local size = #tags
            local i = 1
            while i <= size do
                content:addline(indent .. tags[i] .. '    ' .. (tags[i + 1] or '') .. '    ' .. (tags[i + 2] or ''),
                    'TransTag')
                i = i + 3
            end
            content:addline('')
        end
    end,

    pos = function(result, content)
        if exist(result.pos) then
            expl(content, '词性')
            vim.tbl_map(function(pos)
                content:addline(indent .. pos_map[pos:sub(1, 1)] .. pos:sub(3) .. '%', 'TransPos')
            end, vim.split(result.pos, '/', { plain = true, trimempry = true }))

            content:addline('')
        end
    end,

    exchange = function(result, content)
        if exist(result.exchange) then
            expl(content, '词形变化')

            vim.tbl_map(function(exc)
                content:addline(indent .. exchange_map[exc:sub(1, 1)] .. '    ' .. exc:sub(3), 'TransExchange')
            end, vim.split(result.exchange, '/', { plain = true, trimempry = true }))

            content:addline('')
        end
    end,

    translation = function(result, content)
        expl(content, '中文翻译')

        vim.tbl_map(function(trs)
            content:addline(indent .. trs, 'TransTranslation')
        end, vim.split(result.translation, '\n', { plain = true, trimempry = true }))

        content:addline('')
    end,


    definition = function(result, content)
        if exist(result.definition) then
            expl(content, '英文注释')

            vim.tbl_map(function(def)
                def = def:gsub('%s+', '', 1)
                content:addline(indent .. def, 'TransDefinition')
            end, vim.split(indent .. result.definition, '\n', { plain = true, trimempry = true }))

            content:addline('')
        end
    end,

    failed = function(content)
        content:addline(icon.notfound .. indent .. '没有找到相关的翻译', 'TransNotFound')
    end,
}

return M
