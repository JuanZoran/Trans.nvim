local api = vim.api
local conf = require('Trans').conf
local new_window = require('Trans.window')

local m_window
local m_result
local m_content

-- content utility
local node = require("Trans.node")
local t = node.text
local it = node.item

local m_indent = '    '

local title = function(str)
    m_content:addline(
        t(it('', 'TransTitleRound'), it(str, 'TransTitle'), it('', 'TransTitleRound'))
    )
end

local exist = function(str)
    return str and str ~= ''
end

local process = {
    title = function()
        local icon = conf.icon
        local line
        if m_result.word:find(' ', 1, true) then
            line = it(m_result.word, 'TransWord')

        else
            line = m_content:format {
                nodes = {
                    it(m_result.word, 'TransWord'),
                    t(
                        it('['),
                        it(exist(m_result.phonetic) and m_result.phonetic or icon.notfound, 'TransPhonetic'),
                        it(']')
                    ),
                    it(m_result.collins and icon.star:rep(m_result.collins) or icon.notfound, 'TransCollins'),
                    it(m_result.oxford == 1 and icon.yes or icon.no)
                },
            }
        end
        m_content:addline(line)
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
                    it(
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

            local f = '%s %2s%%'
            for pos in vim.gsplit(m_result.pos, '/', true) do
                m_content:addline(
                    it(m_indent .. f:format(pos_map[pos:sub(1, 1)], pos:sub(3)), 'TransPos')
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
                    it(m_indent .. exchange_map[exc:sub(1, 1)] .. interval .. exc:sub(3), 'TransExchange')
                )
            end

            m_content:newline('')
        end
    end,

    translation = function()
        if exist(m_result.translation) then
            title('中文翻译')

            for trs in vim.gsplit(m_result.translation, '\n', true) do
                m_content:addline(
                    it(m_indent .. trs, 'TransTranslation')
                )
            end
        end

        m_content:newline('')
    end,

    definition = function()
        if exist(m_result.definition) then
            title('英文注释')

            for def in vim.gsplit(m_result.definition, '\n', true) do
                def = def:gsub('^%s+', '', 1) -- TODO :判断是否需要分割空格
                m_content:addline(
                    it(m_indent .. def, 'TransDefinition')
                )
            end

            m_content:newline('')
        end
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

        m_window:try_close {
            callback = function()
                m_window:reopen {
                    win_opt = {
                        relative = 'editor',
                        row = 1,
                        col = vim.o.columns - m_window.width - 3,
                    },
                    opt = {
                        callback = function()
                            m_window:bufset('bufhidden', 'wipe')
                            m_window:set('wrap', true)
                        end
                    },
                }

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
            end
        }
    end,

    close = function()
        pcall(api.nvim_del_autocmd, cmd_id)
        m_window:try_close { wipeout = true }
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

    play = function()
        m_result.word:play()
    end,
}


local function handle()
    local hover = conf.hover
    if m_result.translation and hover.auto_play then
        local ok = pcall(action.play)
        if not ok then
            vim.notify('自动发音失败， 请检查README发音部分', vim.log.WARN)
        end
    end

    for _, field in ipairs(conf.order) do
        process[field]()
    end

    for act, key in pairs(hover.keymap) do
        vim.keymap.set('n', key, action[act], { buffer = true, silent = true })
    end
end

local function online_query(word)
    local lists = {}
    local engines = conf.engines
    local size = #engines
    local icon = conf.icon
    local error_msg = icon.notfound .. '    没有找到相关的翻译'
    m_window:set_height(1)
    local origin_width = m_window.width
    m_window:set_width(error_msg:width())

    if size == 0 then
        m_content:addline(it(error_msg, 'TransFailed'))
        m_window:open()
        return
    else
        m_window:open()
        for i = 1, size do
            lists[size] = require('Trans.query.' .. engines[i])(word)
        end
    end

    local cell = icon.cell
    local spinner = require('Trans.ui.spinner')[conf.hover.spinner]
    local range = #spinner

    local timeout = conf.hover.timeout
    local interval = math.floor(timeout / (m_window.width - spinner[1]:width()))
    local width = m_window.width

    local f = '%s %s'
    require('Trans.util.animation')({
        times = width,
        interval = interval,
        frame = function(self, times)
            m_content:wipe()
            for i, v in ipairs(lists) do
                local res = v.value
                if res then
                    m_result = res
                    m_window:set_width(origin_width)
                    handle()
                    m_content:attach()

                    m_window.height = m_content:actual_height(true)
                    m_window:open {
                        animation = 'fold',
                    }

                    self.run = false
                    return

                elseif res == false then
                    table.remove(lists, i)
                    size = size - 1
                end
            end

            local line
            if size == 0 or times == width then
                line = it(error_msg, 'TransFailed')
                self.run = false
            else
                line = it(f:format(spinner[times % range + 1], cell:rep(times)), 'MoreMsg')
            end

            m_content:addline(line)
            m_content:attach()
        end,
    }):display()
end

return function(word)
    vim.validate {
        word = { word, 's' },
    }

    local hover = conf.hover
    m_window = new_window(false, {
        relative  = 'cursor',
        width     = hover.width,
        height    = hover.height,
        title     = hover.title,
        border    = hover.border,
        animation = hover.animation,
        col       = 1,
        row       = 1,
    })

    m_window:set('wrap', true)
    m_content = m_window:new_content()

    m_result = require('Trans.query.offline')(word)
    if m_result then
        handle()
        local height = m_content:actual_height(true)
        if height < m_window.height then
            m_window:set_height(height)
        end
        m_window:open()
    else
        online_query(word)
    end

    -- Auto Close
    if hover.auto_close_events then
        cmd_id = api.nvim_create_autocmd(
            hover.auto_close_events, {
            buffer = 0,
            callback = function()
                m_window:try_close { wipeout = true }
                try_del_keymap()
                api.nvim_del_autocmd(cmd_id)
            end,
        })
    end
end
