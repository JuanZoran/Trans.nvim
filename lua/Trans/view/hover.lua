local api = vim.api
local conf = require('Trans').conf

local m_window
local m_result
local m_content
-- content utility
local text
local item

local m_indent = '    '

local title = function(str)
    m_content:addline(
        text(
            item('', 'TransTitleRound'),
            item(str, 'TransTitle'),
            item('', 'TransTitleRound')
        )
    )
end

local exist = function(str)
    return str and str ~= ''
end


local process = {
    title = function()
        local icon = conf.icon

        m_content:addline(
            m_content:format(
                item(m_result.word, 'TransWord'),
                text(
                    item('['),
                    item(exist(m_result.phonetic) and m_result.phonetic or icon.notfound, 'TransPhonetic'),
                    item(']')
                ),
                item(m_result.collins and icon.star:rep(m_result.collins) or icon.notfound, 'TransCollins'),
                item(m_result.oxford == 1 and icon.yes or icon.no)
            )
        )
    end,

    tag = function()
        if exist(m_result.tag) then
            title('标签')
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

            local tags = {}
            local size = 0
            local interval = '    '
            for tag in vim.gsplit(m_result.tag, ' ', true) do
                size = size + 1
                tags[size] = tag_map[tag]
            end


            for i = 1, size, 3 do
                m_content:addline(
                    item(
                        m_indent ..
                        tags[i] ..
                        (tags[i + 1] and interval .. tags[i + 1] ..
                            (tags[i + 2] and interval .. tags[i + 2] or '') or ''),
                        'TransTag'
                    )
                )
            end

            m_content:newline('')
        end
    end,

    pos = function()
        if exist(m_result.pos) then
            title('词性')
            local pos_map = {
                a = '代词pron         ',
                c = '连接词conj       ',
                i = '介词prep         ',
                j = '形容词adj        ',
                m = '数词num          ',
                n = '名词n            ',
                p = '代词pron         ',
                r = '副词adv          ',
                u = '感叹词int        ',
                v = '动词v            ',
                x = '否定标记not      ',
                t = '不定式标记infm   ',
                d = '限定词determiner ',
            }
            for pos in vim.gsplit(m_result.pos, '/', true) do
                m_content:addline(
                    item(m_indent .. pos_map[pos:sub(1, 1)] .. pos:sub(3) .. '%', 'TransPos')
                )
            end

            m_content:newline('')
        end
    end,

    exchange = function()
        if exist(m_result.exchange) then
            title('词形变化')
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
            local interval = '    '

            for exc in vim.gsplit(m_result.exchange, '/', true) do
                m_content:addline(
                    item(m_indent .. exchange_map[exc:sub(1, 1)] .. interval .. exc:sub(3), 'TransExchange')
                )
            end

            m_content:newline('')
        end
    end,

    translation = function()
        title('中文翻译')

        for trs in vim.gsplit(m_result.translation, '\n', true) do
            m_content:addline(
                item(m_indent .. trs, 'TransTranslation')
            )
        end

        m_content:newline('')
    end,

    definition = function()
        if exist(m_result.definition) then
            title('英文注释')

            for def in vim.gsplit(m_result.definition, '\n', true) do
                def = def:gsub('^%s+', '', 1) -- TODO :判断是否需要分割空格
                m_content:addline(
                    item(m_indent .. def, 'TransDefinition')
                )
            end

            m_content:newline('')
        end
    end,

    failed = function()
        m_content:addline(
            item(conf.icon.notfound .. m_indent .. '没有找到相关的翻译', 'TransFailed')
        )

        m_window:set_width(m_content.lines[1]:width())
    end,
}


local try_del_keymap = function()
    for _, key in pairs(conf.hover.keymap) do
        pcall(vim.keymap.del, 'n', key, { buffer = true })
    end
end


local cmd_id
local pin
local next
local action
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
    end,

    play = vim.fn.has('linux') == 1 and function()
        vim.fn.jobstart('echo ' .. m_result.word .. ' | festival --tts')
    end or function()
        local file = debug.getinfo(1, "S").source:sub(2):match('(.*)lua/') .. 'tts/say.js'
        vim.fn.jobstart('node ' .. file .. ' ' .. m_result.word)
    end,
}


return function(word)
    vim.validate {
        word = { word, 's' },
    }

    m_result = require('Trans.query.offline')(word) -- 目前只处理了本地数据库的查询
    local hover = conf.hover

    m_window = require("Trans.window")(false, {
        relative = 'cursor',
        width    = hover.width,
        height   = hover.height,
        title    = hover.title,
        border   = hover.border,
        col      = 2,
        row      = 2,
    })

    m_window.animation = hover.animation
    m_content = m_window.contents[1]

    if not text then
        text = m_content.text_wrap
        item = m_content.item_wrap
    end

    if m_result then
        if hover.auto_play then action.play() end

        for _, field in ipairs(conf.order) do
            process[field]()
        end

        for act, key in pairs(hover.keymap) do
            vim.keymap.set('n', key, action[act], { buffer = true, silent = true })
        end
    else
        process.failed()
    end

    m_window:draw()

    local height = m_content:actual_height(true)
    if height < m_window.height then
        m_window:set_height(height)
    end

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
end
