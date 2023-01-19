local conf = require('Trans').conf
local icon = conf.icon

local m_window = require('Trans.window')
local m_result
local m_indent = '    '

local title = function(str)
    local wrapper = m_window.text_wrap()
    -- wrapper('', 'TransTitleRound')
    wrapper('', 'TransTitleRound')
    wrapper(str, 'TransTitle')
    wrapper('', 'TransTitleRound')
    -- wrapper('', 'TransTitleRound')
end

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


local exist = function(str)
    return str and str ~= ''
end

local process = {
    title = function()
        local line = m_window.line_wrap()
        line.add_item(
            m_result.word,
            'TransWord'
        )

        line.add_item(
            '[' .. (exist(m_result.phonetic) and m_result.phonetic or icon.notfound) .. ']',
            'TransPhonetic'
        )

        line.add_item(
            (exist(m_result.collins) and icon.star:rep(m_result.collins) or icon.notfound),
            'TransCollins'
        )
        line.add_item(
            (m_result.oxford == 1 and icon.yes or icon.no)
        )
        line.load()
    end,

    tag = function()
        if exist(m_result.tag) then
            title('标签')
            local tags = {}
            local size = 0
            local interval = '    '
            for tag in vim.gsplit(m_result.tag, ' ', true) do
                size = size + 1
                tags[size] = tag_map[tag]
            end

            for i = 1, size, 3 do
                m_window.addline(
                    m_indent .. tags[i] .. interval .. (tags[i + 1] or '') .. interval .. (tags[i + 2] or ''),
                    'TransTag'
                )
            end
            m_window.addline('')
        end
    end,

    pos = function()
        if exist(m_result.pos) then
            title('词性')

            for pos in vim.gsplit(m_result.pos, '/', true) do
                m_window.addline(
                    m_indent .. pos_map[pos:sub(1, 1)] .. pos:sub(3) .. '%',
                    'TransPos'
                )
            end

            m_window.addline('')
        end
    end,

    exchange = function()
        if exist(m_result.exchange) then
            title('词形变化')
            local interval = '    '

            for exc in vim.gsplit(m_result.exchange, '/', true) do
                m_window.addline(
                    m_indent .. exchange_map[exc:sub(1, 1)] .. interval .. exc:sub(3),
                    'TransExchange'
                )
            end

            m_window.addline('')
        end
    end,

    translation = function()
        title('中文翻译')

        for trs in vim.gsplit(m_result.translation, '\n', true) do
            m_window.addline(
                m_indent .. trs,
                'TransTranslation'
            )
        end

        m_window.addline('')
    end,

    definition = function()
        if exist(m_result.definition) then
            title('英文注释')

            for def in vim.gsplit(m_result.definition, '\n', true) do
                def = def:gsub('^%s+', '', 1) -- TODO :判断是否需要分割空格
                m_window.addline(
                    m_indent .. def,
                    'TransDefinition'
                )
            end

            m_window.addline('')
        end
    end,

    failed = function()
        m_window.addline(
            icon.notfound .. m_indent .. '没有找到相关的翻译',
            'TransFailed'
        )
    end,
}


local function handle(word)
    vim.validate {
        word = { word, 's' },
    }

    -- 目前只处理了本地数据库的查询
    m_result       = require('Trans.query.offline')(word)
    local hover    = conf.window.hover
    hover.relative = 'cursor'
    hover.col      = 2
    hover.row      = 2
    m_window.init(false, hover)


    if m_result then
        for _, field in ipairs(conf.order) do
            process[field]()
        end
    else
        process.failed()
    end

    m_window.draw()
    -- Auto Close
    vim.api.nvim_create_autocmd(
        { 'InsertEnter', 'CursorMoved', 'BufLeave', }, {
        buffer = 0,
        once = true,
        callback = m_window.try_close,
    })


    m_window.set('wrap', true)
    m_window.adjust()
end

return handle
