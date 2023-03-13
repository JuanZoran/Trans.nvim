local Trans = require('Trans')

---@class hover
---@field queue table @hover queue for all hover instances
---@field buffer buffer @buffer for hover window
---@field destroy_funcs table @functions to be executed when hover window is closed
---@field window window @hover window
---@field opts table @options for hover window
---@field opts.title string @title for hover window
---@field opts.width number @width for hover window
---@field opts.height number @height for hover window
---@field opts.animation boolean @whether to use animation for hover window
---@field opts.fallback_message string @message to be displayed when hover window is waiting for data
---@field opts.spinner string @spinner to be displayed when hover window is waiting for data
---@field opts.icon table @icons for hover window
---@field opts.icon.notfound string @icon for not found
---@field opts.icon.yes string @icon for yes
---@field opts.icon.no string @icon for no
---@field opts.icon.star string @icon for star
---@field opts.icon.cell string @icon for cell used in waitting animation


local M = Trans.metatable('frontend.hover', {
    ns    = vim.api.nvim_create_namespace('TransHoverWin'),
    queue = {},
})
M.__index = M

---Create a new hover instance
---@return hover new_instance
function M.new()
    local new_instance = {
        buffer = Trans.buffer.new(),
        destroy_funcs = {},
    }
    M.queue[#M.queue + 1] = new_instance

    return setmetatable(new_instance, M)
end

---Get the first active instances
---@return hover
function M.get_active_instance()
    M.clear_dead_instance()
    return M.queue[1]
end

---Clear dead instance
function M.clear_dead_instance()
    local queue = M.queue
    for i = #queue, 1, -1 do
        if not queue[i]:is_available() then
            queue[i]:destroy()
            table.remove(queue, i)
        end
    end
end

---Destroy hover instance and execute destroy functions
function M:destroy()
    for _, func in ipairs(self.destroy_funcs) do
        func(self)
    end

    self.window:try_close()
    self.buffer:destroy()
end

---Init hover window
---@param opts table @window options: width, height
---@return unknown
function M:init_window(opts)
    opts           = opts or {}
    local win_opts = opts.win_opts or {}
    opts.win_opts  = win_opts
    local m_opts   = self.opts


    opts.ns           = self.ns
    opts.buffer       = self.buffer
    win_opts.col      = 1
    win_opts.row      = 1
    win_opts.relative = 'cursor'
    win_opts.title    = m_opts.title
    if win_opts.title then
        win_opts.title_pos = 'center'
    end
    win_opts.width  = win_opts.width or m_opts.width
    win_opts.height = win_opts.height or m_opts.height
    opts.animation  = m_opts.animation



    self.window = Trans.window.new(opts)
    return self.window
end

---Wait for data
---@param tbl table @table to be checked
---@param name string @key to be checked
---@param timeout number @timeout for waiting
function M:wait(tbl, name, timeout)
    local opts    = self.opts
    local width   = opts.width
    local spinner = Trans.style.spinner[self.opts.spinner]
    local size    = #spinner
    local cell    = self.opts.icon.cell


    local function update_text(times)
        return spinner[times % size + 1] .. (cell):rep(times)
    end

    self:init_window({
        win_opts = {
            height = 1,
            width = width,
        }
    })

    local interval = math.floor(timeout / width)
    local pause = Trans.util.pause
    for i = 1, width do
        if tbl[name] ~= nil then break end
        self.buffer[1] = update_text(i)
        self.buffer:add_highlight(1, 'MoreMsg')
        pause(interval)
    end

    -- TODO : End waitting animation
end

---Process data and display it in hover window
---@param data table @data to be processed
function M:process(data)
    vim.pretty_print(data.result)
    print('TODO: process data')
end

---Check if hover window and buffer are valid
---@return boolean @whether hover window and buffer are valid
function M:is_available()
    return self.buffer:is_valid() and self.window:is_valid()
end

return M
-- local error_msg = conf.icon.notfound .. '    没有找到相关的翻译'
-- local buffer = require('Trans.buffer')()

-- local node = require('Trans.node')
-- local it, t, f = node.item, node.text, node.format

-- local function handle_result(result)
--     local icon = conf.icon
--     local notfound = icon.notfound
--     local indent = '    '

--     local word = result.title.word
--     if hover.auto_play then
--         string.play(word:isEn() and word or result.definition)
--     end

--     local addtitle = function(title)
--         buffer:addline {
--             it('', 'TransTitleRound'),
--             it(title, 'TransTitle'),
--             it('', 'TransTitleRound'),
--         }
--     end

--     local process = {
--         title = function(title)
--             local oxford   = title.oxford
--             local collins  = title.collins
--             local phonetic = title.phonetic

--             if not phonetic and not collins and not oxford then
--                 buffer:addline(it(word, 'TransWord'))

--             else
--                 buffer:addline(f {
--                     width = hover.width,
--                     text = t {
--                         it(word, 'TransWord'),
--                         t {
--                             it('['),
--                             it((phonetic and phonetic ~= '') and phonetic or notfound, 'TransPhonetic'),
--                             it(']')
--                         },
--                         it(collins and icon.star:rep(collins) or notfound, 'TransCollins'),
--                         it(oxford == 1 and icon.yes or icon.no)
--                     },
--                 })
--             end
--         end,

--         tag = function(tag)
--             addtitle('标签')
--             local tag_map = {
--                 zk    = '中考',
--                 gk    = '高考',
--                 ky    = '考研',
--                 cet4  = '四级',
--                 cet6  = '六级',
--                 ielts = '雅思',
--                 toefl = '托福',
--                 gre   = 'gre ',
--             }

--             local tags = {}
--             local size = 0
--             local interval = '    '
--             for _tag in vim.gsplit(tag, ' ', true) do
--                 size = size + 1
--                 tags[size] = tag_map[_tag]
--             end


--             for i = 1, size, 3 do
--                 buffer:addline(
--                     it(
--                         indent .. tags[i] ..
--                         (tags[i + 1] and interval .. tags[i + 1] ..
--                             (tags[i + 2] and interval .. tags[i + 2] or '') or ''),
--                         'TransTag'
--                     )
--                 )
--             end

--             buffer:addline('')
--         end,

--         pos = function(pos)
--             addtitle('词性')
--             local pos_map = {
--                 a = '代词pron         ',
--                 c = '连接词conj       ',
--                 i = '介词prep         ',
--                 j = '形容词adj        ',
--                 m = '数词num          ',
--                 n = '名词n            ',
--                 p = '代词pron         ',
--                 r = '副词adv          ',
--                 u = '感叹词int        ',
--                 v = '动词v            ',
--                 x = '否定标记not      ',
--                 t = '不定式标记infm   ',
--                 d = '限定词determiner ',
--             }

--             local s = '%s %2s%%'
--             for _pos in vim.gsplit(pos, '/', true) do
--                 buffer:addline(
--                     it(indent .. s:format(pos_map[_pos:sub(1, 1)], _pos:sub(3)), 'TransPos')
--                 )
--             end

--             buffer:addline('')
--         end,

--         exchange = function(exchange)
--             addtitle('词形变化')
--             local exchange_map = {
--                 ['p'] = '过去式      ',
--                 ['d'] = '过去分词    ',
--                 ['i'] = '现在分词    ',
--                 ['r'] = '比较级      ',
--                 ['t'] = '最高级      ',
--                 ['s'] = '复数        ',
--                 ['0'] = '原型        ',
--                 ['1'] = '类别        ',
--                 ['3'] = '第三人称单数',
--                 ['f'] = '第三人称单数',
--             }
--             local interval = '    '
--             for exc in vim.gsplit(exchange, '/', true) do
--                 buffer:addline(
--                     it(indent .. exchange_map[exc:sub(1, 1)] .. interval .. exc:sub(3), 'TransExchange')
--                 )
--             end

--             buffer:addline('')
--         end,

--         translation = function(translation)
--             addtitle('中文翻译')

--             for trs in vim.gsplit(translation, '\n', true) do
--                 buffer:addline(
--                     it(indent .. trs, 'TransTranslation')
--                 )
--             end

--             buffer:addline('')
--         end,

--         definition = function(definition)
--             addtitle('英文注释')

--             for def in vim.gsplit(definition, '\n', true) do
--                 def = def:gsub('^%s+', '', 1) -- TODO :判断是否需要分割空格
--                 buffer:addline(
--                     it(indent .. def, 'TransDefinition')
--                 )
--             end

--             buffer:addline('')
--         end,
--     }

--     buffer:set('modifiable', true)
--     for _, field in ipairs(conf.order) do
--         local value = result[field]
--         if value and value ~= '' then
--             process[field](value)
--         end
--     end
--     buffer:set('modifiable', false)
-- end

-- local function open_window(opts)
--     opts = opts or {}

--     local col      = opts.col or 1
--     local row      = opts.row or 1
--     local width    = opts.width or hover.width
--     local height   = opts.height or hover.height
--     local relative = opts.relative or 'cursor'

--     return require('Trans.window') {
--         col       = col,
--         row       = row,
--         buf       = buffer,
--         relative  = relative,
--         width     = width,
--         height    = height,
--         title     = hover.title,
--         border    = hover.border,
--         animation = hover.animation,
--         ns        = require('Trans').ns,
--     }
-- end

-- local function handle_keymap(win, word)
--     local keymap = hover.keymap
--     local cur_buf = api.nvim_get_current_buf()
--     local del = vim.keymap.del
--     local function try_del_keymap()
--         for _, key in pairs(keymap) do
--             pcall(del, 'n', key)
--         end
--     end

--     local lock = false
--     local cmd_id
--     local next
--     local action = {
--         pageup = function()
--             buffer:normal('gg')
--         end,

--         pagedown = function()
--             buffer:normal('G')
--         end,

--         pin = function()
--             if lock then
--                 error('请先关闭窗口')
--             else
--                 lock = true
--             end
--             pcall(api.nvim_del_autocmd, cmd_id)
--             local width, height = win.width, win.height
--             local col = vim.o.columns - width - 3
--             local buf = buffer.bufnr
--             local run = win:try_close()
--             run(function()
--                 local w, r = open_window {
--                     width = width,
--                     height = height,
--                     relative = 'editor',
--                     col = col,
--                 }

--                 next = w.winid
--                 win = w
--                 r(function()
--                     w:set('wrap', true)
--                 end)

--                 del('n', keymap.pin)
--                 api.nvim_create_autocmd('BufWipeOut', {
--                     callback = function(opt)
--                         if opt.buf == buf or opt.buf == cur_buf then
--                             lock = false
--                             api.nvim_del_autocmd(opt.id)
--                         end
--                     end
--                 })
--             end)
--         end,

--         close = function()
--             pcall(api.nvim_del_autocmd, cmd_id)
--             local run = win:try_close()
--             run(function()
--                 buffer:delete()
--             end)
--             try_del_keymap()
--         end,

--         toggle_entry = function()
--             if lock and win:is_valid() then
--                 local prev = api.nvim_get_current_win()
--                 api.nvim_set_current_win(next)
--                 next = prev
--             else
--                 del('n', keymap.toggle_entry)
--             end
--         end,

--         play = function()
--             if word then
--                 word:play()
--             end
--         end,
--     }
--     local set = vim.keymap.set
--     for act, key in pairs(hover.keymap) do
--         set('n', key, action[act])
--     end

--     if hover.auto_close_events then
--         cmd_id = api.nvim_create_autocmd(
--             hover.auto_close_events, {
--             buffer = 0,
--             callback = action.close,
--         })
--     end
-- end

-- local function online_query(win, word)
--     local lists = {
--         remove = table.remove
--     }
--     local engines = conf.engines
--     local size = #engines
--     local icon = conf.icon
--     local error_line = it(error_msg, 'TransFailed')
--     if size == 0 then
--         buffer:addline(error_line)
--         return
--     end

--     for i = 1, size do
--         lists[i] = require('Trans.query.' .. engines[i])(word)
--     end
--     local cell      = icon.cell
--     local timeout   = hover.timeout
--     local spinner   = require('Trans.style.spinner')[hover.spinner]
--     local range     = #spinner
--     local interval  = math.floor(timeout / (win.width - spinner[1]:width()))
--     local win_width = win.width

--     local s = '%s %s'
--     local width, height = hover.width, hover.height
--     local function waitting_result(this, times)
--         for i = size, 1, -1 do
--             local res = lists[i][1]
--             if res then
--                 buffer:wipe()
--                 win:set_width(width)
--                 handle_result(res)
--                 height = math.min(height, buffer:height(width))

--                 win:expand {
--                     field = 'height',
--                     target = height,
--                 }
--                 this.run = false
--                 return
--             elseif res == false then
--                 lists:remove(i)
--                 size = size - 1
--             end
--         end

--         if size == 0 or times == win_width then
--             buffer:addline(error_line, 1)
--             this.run = false
--         else
--             buffer:addline(it(s:format(spinner[times % range + 1], cell:rep(times)), 'MoreMsg'), 1)
--         end
--     end

--     buffer:set('modifiable', true)
--     local run = require('Trans.util.display') {
--         times = win_width,
--         interval = interval,
--         frame = waitting_result,
--     }

--     run(function()
--         buffer:set('modifiable', false)
--     end)
-- end

-- ---处理不同hover模式的窗口
-- ---@param word string 待查询的单词
-- return function(word)
--     buffer:init()
--     local result = require('Trans.query.offline')(word)

--     if result then
--         handle_result(result)
--         local width = hover.width
--         local win, run = open_window {
--             width = width,
--             height = math.min(buffer:height(width), hover.height)
--         }

--         run(function()
--             win:set('wrap', true)
--             handle_keymap(win, word)
--         end)

--     else
--         local win, run = open_window {
--             width = error_msg:width(),
--             height = 1,
--         }

--         run(function()
--             win:set('wrap', true)
--             handle_keymap(win, word)
--             online_query(win, word)
--         end)
--     end
-- end
