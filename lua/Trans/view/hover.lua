local api = vim.api
local conf = require('Trans').conf
local icon = conf.icon

local m_window
local m_result
local m_content
local m_indent = '    '

local title = function(str)
    local wrapper = m_content:line_wrap()
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
        local line = m_content:items_wrap()
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
                m_content:addline(
                    m_indent .. tags[i] .. interval .. (tags[i + 1] or '') .. interval .. (tags[i + 2] or ''),
                    'TransTag'
                )
            end

            m_content:addline('')
        end
    end,

    pos = function()
        if exist(m_result.pos) then
            title('词性')

            for pos in vim.gsplit(m_result.pos, '/', true) do
                m_content:addline(
                    m_indent .. pos_map[pos:sub(1, 1)] .. pos:sub(3) .. '%',
                    'TransPos'
                )
            end

            m_content:addline('')
        end
    end,

    exchange = function()
        if exist(m_result.exchange) then
            title('词形变化')
            local interval = '    '

            for exc in vim.gsplit(m_result.exchange, '/', true) do
                m_content:addline(
                    m_indent .. exchange_map[exc:sub(1, 1)] .. interval .. exc:sub(3),
                    'TransExchange'
                )
            end

            m_content:addline('')
        end
    end,

    translation = function()
        title('中文翻译')

        for trs in vim.gsplit(m_result.translation, '\n', true) do
            m_content:addline(
                m_indent .. trs,
                'TransTranslation'
            )
        end

        m_content:addline('')
    end,

    definition = function()
        if exist(m_result.definition) then
            title('英文注释')

            for def in vim.gsplit(m_result.definition, '\n', true) do
                def = def:gsub('^%s+', '', 1) -- TODO :判断是否需要分割空格
                m_content:addline(
                    m_indent .. def,
                    'TransDefinition'
                )
            end

            m_content:addline('')
        end
    end,

    failed = function()
        m_content:addline(
            icon.notfound .. m_indent .. '没有找到相关的翻译',
            'TransFailed'
        )
    end,
}


local cmd_id
local pin = false

local try_del_keymap = function()
    for _, key in pairs(conf.hover.keymap) do
        pcall(vim.keymap.del, 'n', key, { buffer = true })
    end
end

local action
local next
action = {
    pageup = function()
        m_window:normal('gg')
    end,

    pagedown = function()
        m_window:normal('G')
    end,

    pin = function()
        if pin then
            error('too many window')
        end

        pcall(api.nvim_del_autocmd, cmd_id)
        m_window:set('wrap', false)

        m_window:try_close(function()
            m_window:reopen(false, {
                relative = 'editor',
                row = 1,
                col = vim.o.columns - m_window.width - 3,
            }, function()
                m_window:set('wrap', true)
            end)

            m_window:bufset('bufhidden', 'wipe')
            vim.keymap.del('n', conf.hover.keymap.pin, { buffer = true })


            --- NOTE : 只允许存在一个pin窗口
            local buf = m_window.bufnr
            pin = true
            local toggle = conf.hover.keymap.toggle_entry
            if toggle then
                next = m_window.winid
                vim.keymap.set('n', toggle, action.toggle_entry, { silent = true, buffer = buf })
            end

            api.nvim_create_autocmd('BufWipeOut', {
                callback = function(opt)
                    if opt.buf == buf then
                        pin = false
                        api.nvim_del_autocmd(opt.id)
                    end
                end
            })
        end)
    end,

    close = function()
        pcall(api.nvim_del_autocmd, cmd_id)
        m_window:set('wrap', false)
        m_window:try_close()
        try_del_keymap()
    end,

    toggle_entry = function()
        if pin and m_window:is_open() then
            local prev = api.nvim_get_current_win()
            api.nvim_set_current_win(next)
            next = prev
        else
            vim.keymap.del('n', conf.hover.keymap.toggle_entry, { buffer = true })
        end
    end
}


return function(word)
    vim.validate {
        word = { word, 's' },
    }

    -- 目前只处理了本地数据库的查询
    m_result    = require('Trans.query.offline')(word)
    local hover = conf.hover
    local opt   = {
        relative = 'cursor',
        width    = hover.width,
        height   = hover.height,
        title    = hover.title,
        border   = hover.border,
        col      = 2,
        row      = 2,
    }

    m_window = require("Trans.window")(false, opt)
    m_window.animation = hover.animation
    m_content = m_window.content

    if m_result then
        for _, field in ipairs(conf.order) do
            process[field]()
        end
    else
        process.failed()
    end

    m_window:draw(true)
    m_window:open(function()
        m_window:set('wrap', true)
    end)



    -- Auto Close
    cmd_id = api.nvim_create_autocmd(
        hover.auto_close_events, {
        buffer = 0,
        callback = function()
            m_window:set('wrap', false)
            m_window:try_close()
            try_del_keymap()
            api.nvim_del_autocmd(cmd_id)
        end,
    })

    for act, key in pairs(hover.keymap) do
        vim.keymap.set('n', key, action[act], { buffer = true, silent = true })
    end
end
