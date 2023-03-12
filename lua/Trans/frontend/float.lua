-- local api = vim.api
-- local conf = require('Trans').conf
-- local buffer = require('Trans.buffer')()

-- local node = require("Trans.node")
-- local t = node.text
-- local it = node.item
-- local f = node.format


-- local engine_map = {
--     baidu   = '百度',
--     youdao  = '有道',
--     iciba   = 'iciba',
--     offline = '本地',
-- }

-- local function set_tag_hl(name, status)
-- local hl = conf.float.tag[status]
-- m_window:set_hl(name, {
--     fg = '#000000',
--     bg = hl,
-- })

-- m_window:set_hl(name .. 'round', {
--     fg = hl,
-- })
-- end

-- local function set_title()
-- local title = m_window:new_content()
-- local github = '  https://github.com/JuanZoran/Trans.nvim'

-- title:addline(
--     title:center(it(github, '@text.uri'))
-- )

-- local f = '%s(%d)'

-- local tags = {}
-- local load_tag = function(engine, index)
--     set_tag_hl(engine, 'wait')
--     local round = engine .. 'round'
--     table.insert(tags, t(
--         it('', round),
--         it(f:format(engine_map[engine], index), engine),
--         it('', round)
--     ))
-- end
-- load_tag('offline', 1)
-- title:addline(unpack(tags))
-- title:newline('')
-- end

-- local action = {
--     quit = function()
--         -- m_window:try_close()
--     end,
-- }

-- local exist = function(str)
--     return str and str ~= ''
-- end

-- local function process()
-- TODO :
-- local icon = conf.icon
-- m_content:addline(m_content:format {
--     nodes = {
--         it(m_result.word, 'TransWord'),
--         t(
--             it('['),
--             it(exist(m_result.phonetic) and m_result.phonetic or icon.notfound, 'TransPhonetic'),
--             it(']')
--         ),
--         it(m_result.collins and icon.star:rep(m_result.collins) or icon.notfound, 'TransCollins'),
--         it(m_result.oxford == 1 and icon.yes or icon.no)
--     },
--     width = math.floor(m_window.width * 0.5)
-- })
-- m_content:addline(it('该窗口还属于实验性功能 .... '))
-- end

-- return function(word)
--     buffer:init()
--     -- TODO :online query
--     -- local float = conf.float
--     vim.notify([[
-- [注意]:
-- float窗口目前还待开发
-- 如果需要input查询功能, 请将窗口改成hover]])
-- local opt = {
--     relative  = 'editor',
--     width     = float.width,
--     height    = float.height,
--     border    = float.border,
--     title     = float.title,
--     animation = float.animation,
--     row       = bit.rshift((vim.o.lines - float.height), 1),
--     col       = bit.rshift((vim.o.columns - float.width), 1),
--     zindex    = 20,
-- }
-- m_window = require('Trans.window')(true, opt)
-- set_title()
-- m_content = m_window:new_content()
-- m_result = require('Trans.query.offline')(word)
-- if m_result then
--     set_tag_hl('offline', 'success')
--     process()
-- else
--     set_tag_hl('offline', 'fail')
-- end

-- m_window:open()
-- m_window:bufset('bufhidden', 'wipe')

-- for act, key in pairs(float.keymap) do
--     m_window:map(key, action[act])
-- end
-- end
