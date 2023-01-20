# Trans.nvim

<!--toc:start-->
- [Trans.nvim](#transnvim)
  - [特点](#特点)
  - [屏幕截图](#屏幕截图)
  - [安装](#安装)
  - [配置](#配置)
  - [快捷键绑定](#快捷键绑定)
  - [高亮组](#高亮组)
  - [声明](#声明)
  - [感谢](#感谢)
  - [待办 (画大饼)](#待办-画大饼)
<!--toc:end-->


## 特点
- 使用纯lua编写
- 大部分功能可以自定义:
  - 高亮
  - 悬浮大小
  - 排版顺序
  - 弹窗大小
  - etc (更多可以查看[配置](#配置))
- **完全离线** 的单词翻译体验 (可能后面会支持在线翻译)
- 支持显示:
  - 柯林斯星级
  - 牛津3000词汇
  - 中文翻译
  - 英文翻译  (不是英译中, 而是用英文解释)
  - 词根
  - etc
- 舒服的排版和`动画`
- 支持 `normal`和 `visual`模式
    > 不支持 visual-block mode
  
- 本地词库单词量: `430w`
  
## 屏幕截图
![ScreenShot](./screenshot.gif)


## 安装
*安装之前, 首先需要明确本插件的依赖:*
- [ECDICT](https://github.com/skywind3000/ECDICT): 插件所用的离线单词数据库
- sqlite.lua: 操作数据库所用的库
- sqlite3: 数据库

由于目前本人只使用 `Packer.nvim` 作为包管理插件, 所以这里以Packer为例:  
**考虑将以下代码复制到的Packer Startup中:**
```lua
use {
    'JuanZoran/Trans.nvim'
    run = 'bash ./install.sh',
    requires = 'kharji/sqlite.lua',
    -- 如果你不需要任何配置的话, 可以直接按照下面的方式启动
    config = require'Trans'.setup
}

```

**如果你想要使用Packer的惰性加载，这里有一个例子**  
```lua
use {
    "JuanZoran/Trans.nvim",
    keys = {
        { 'v', 'mm' }, -- 换成其他你想用的key即可
        { 'n', 'mm' },
        { 'n', 'mi' },
    },
    run = 'bash ./install.sh', -- 自动下载使用的本地词库
    requires = 'kharji/sqlite.lua',
    config = function()
        require("Trans").setup {} -- 启动Trans
        vim.keymap.set({"v", 'n'}, "mm", '<Cmd>Translate<CR>', { desc = ' Translate' }) -- 自动判断virtual 还是 normal 模式
        vim.keymap.set("n", "mi", "<Cmd>TranslateInput<CR>", { desc = ' Translate' })
    end
}
```

**注意事项**:
- `install.sh`
  - 使用了 `wget`下载词库, 安装请确保你的环境变量中存在wget
  - install.sh 下载后会自动将词库解压, 并移动到 `$HOME/.vim/dict`文件夹下
  - 目前仅在 `Ubuntu22.04`的环境下测试通过
    > 如果上述条件不符合, 请删掉 `run = 'install.sh'`部分, 考虑手动安装词库
    > 如果上述条件满足, 仍出现问题, 欢迎在issue里向我反馈,我会及时尝试解决

- 下载词典的过程中, 需要能够 `流畅的访问github下载`
    > 词库文件压缩包大小为: **281M**
    > 解压缩后的大小大概为: 1.2G

- 安装后如果不能正常运行, 请尝试检查一下问题:
  - 本机是否已经安装了 `sqlite3`
    > Linux下安装:
    > `sudo pacman -S sqlite # Arch`
    > `sudo apt-get install sqlite3 libsqlite3-dev # Ubuntu`
    
  > 后续会增加 `healthcheck` 进行检查


## 配置
```lua
require'Trans'.setup {
    view = {
        input = 'float',
        n = 'hover',
        v = 'hover',
    },
    window = {
        border = 'rounded',
        animation = true,
        hover = {
            width = 36,
            height = 26,
        },
        float = {
            width = 0.8,
            height = 0.8,
        },
    },

    order = {
        -- offline = {
        'title',
        'tag',
        'pos',
        'exchange',
        'translation',
        'definition',
        -- },
        -- online = {
        --     -- TODO
        -- },
    },
    icon = {
        title = ' ', --  
        star = '',
        -- notfound = ' ',
        -- yes = ' ',
        -- no = ' '
        -- star = '⭐',
        notfound = '❔',
        yes = '✔️',
        no = '❌'
    },
    db_path = '$HOME/.vim/dict/ultimate.db',
    -- TODO :
    -- engine = {
    --     -- TODO
    --     'offline',
    -- }
    keymap = {
        -- TODO : More action support
        hover = {
            pageup = '[[',
            pagedown = ']]',
        },
    },
    -- history = {
    --     -- TOOD
    -- }

    -- TODO  add online translate engine
    -- online_search = {
    --     enable = false,
    --     engine = {},
    -- }

    -- TODO register word
}
```

## 快捷键绑定
**示例:**
> 示例中展示, 将`mm`映射成快捷键
```lua
-- normal-mode
vim.keymap.set({'n', 'v'}, 'mm', '<Cmd>Translate<CR>')
vim.keymap.set('n', 'mi', '<Cmd>TranslateInput<CR>')

```

## 高亮组
```lua
-- TODO : add explanation

```
## 声明
- 本插件词典基于[ECDICT](https://github.com/skywind3000/ECDICT)

## 感谢
- [ECDICT](https://github.com/skywind3000/ECDICT)       本地词典的提供
- [sqlite.lua](https://github.com/kharji/sqlite.lua)    数据库访问
- [T.vim](https://github.com/sicong-li/T.vim)           灵感来源

## 待办 (画大饼)
- ~~移动光标自动关闭窗口~~
- 多风格样式
- 历史查询结果保存
- 在线多引擎异步查询
- 快捷键定义
- 自动读音
- `句子翻译` | `中翻英` 的支持
- 重新录制屏幕截图示例
