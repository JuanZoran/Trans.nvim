# Trans.nvim
- [Trans.nvim](#transnvim)
  - [特点](#特点)
  - [屏幕截图](#屏幕截图)
  - [安装](#安装)
  - [配置](#配置)
  - [快捷键绑定](#快捷键绑定)
  - [高亮组](#高亮组)
  - [声明](#声明)
  - [感谢](#感谢)
- [TODO](#todo)

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
- 支持 `normal`和 `visual`模式
> visual-select 不支持
  
- 词库单词量: `43w`
  
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
    config = require'Trans'.setup{}
}
```
**注意事项**:
- `install.sh`
  - 使用了 `wget`下载词库, 安装请确保你的环境变量中存在wget
  - install.sh 下载后会自动将词库解压, 并移动到 `$HOME/.vim/dict`文件夹下
  - 目前仅在 `Ubuntu22.04`的环境下测试通过
    > 如果上述条件不符合, 请删掉 `run = 'install.sh'`部分, 考虑手动安装词库
    > 如果上述条件满足, 仍出现问题, 欢迎在issure里向我反馈,我会及时尝试解决

- 下载词典的过程中, 需要能够 `流畅的访问github下载`
    > 词库文件压缩包大小为: **281M**
    > 解压缩后的大小大概为: 1.2G

- 安装后如果不能正常运行, 请尝试检查一下问题:
  - 本机是否已经安装了 `sqlite3`
    > Linux下安装:
    > `sudo pacman -S sqlite # Arch`
    > `sudo apt-get install sqlite3 libsqlite3-dev # Ubuntu`
    
  - `$HOME/.vim/dict` 文件夹是否存在
  - 后续会尝试 `healthcheck` 进行检查


## 配置
```lua
require'Trans'.setup{
    display = {
       style        = 'minimal',
       max_height   = 50,        -- 小于0代表无限制
       max_width    = 50,
       collins_star = true,      -- 是否显示柯林斯星级
       oxford       = true,      -- 是否显示为牛津3000词汇
       wrap         = true,      -- 是否折叠超出width的部分
       border_style = 'rounded', -- 边框属性
       view         = 'cursor',  -- TODO, 目前还未测试, 请不要更改
       offset_x     = 2,         -- 弹窗相对光标的偏移
       offset_y     = 2,
    },
    order = {   -- 排版的顺序
        'title', -- 如果你不想显示某一部分, 可以直接删除该部分
        'tag',
        'pos',
        'exchange',
        'zh',
        'en',
    },

    db_path = '$HOME/.vim/dict/ultimate.db', -- 词典的数据库位置
                                             -- 如果你是手动安装, 可以自定义
    icon = {
        star = '⭐',        -- 柯林斯星级图标
        isOxford = '✔',     -- 牛津3000词汇的标志
        notOxford = ''
    },
    auto_close = true,      -- 移动光标关闭弹窗
}
```

## 快捷键绑定
**示例:**
> 示例中展示, 将`mm`映射成快捷键
```lua
-- normal-mode
vim.keymap.set('n', 'mm', '<Cmd>TranslateCursorWord<CR>')

-- visual-mode
vim.keymap.set('v', 'mm', '<Esc><Cmd>TranslateSelectWord<CR>')

```

## 高亮组
```lua
hlgroup = {
    word     = 'TransWord',
    phonetic = 'TransPhonetic',
    ref      = 'TransRef',    -- 如: 标签: | 中文翻译: 之类的前导词
    tag      = 'TransTag',
    exchange = 'TransExchange',
    pos      = 'TransPos',
    zh       = 'TransZh',
    en       = 'TransEn',
}

```
## 声明
- 本插件词典基于[ECDICT](https://github.com/skywind3000/ECDICT)

## 感谢
- [ECDICT](https://github.com/skywind3000/ECDICT)
- [sqlite.lua](https://github.com/kharji/sqlite.lua)
- [T.vim](https://github.com/sicong-li/T.vim)

# TODO
- 多风格样式
- ~~移动光标自动关闭窗口~~
