# Trans.nvim

<!--toc:start-->
- [Trans.nvim](#transnvim)
  - [特点](#特点)
  - [屏幕截图](#屏幕截图)
  - [安装](#安装)
  - [Festival配置](#festival配置)
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
  - `舒服窗口动画`
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
### 演示
https://user-images.githubusercontent.com/107862700/213752097-2eee026a-ddee-4531-bf80-ba2cbc8b44ef.mp4

### 主题
> 如果你有更美观或者更适合的配色, 欢迎提PR  
> 主题配色在: `lua/Trans/theme.lua`文件中，你只需要添加你主题的表就可以了


- `default`
![default](./theme/default.png) 

- `dracula`
![dracula](./theme/dracula.png) 

- `tokyonight`
![tokyonight](./theme/tokyonight.png) 


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
    config = function ()
        require'Trans'.setup{
            -- your configuration here
        }
    end
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

- **`auto_play`** 使用步骤:
    > linux 只需要安装`festival`  
    > sudo apt-get install festival festvox-kallpc16k  
    > ***如果你想要设置音色，发音可以访问:*** [Festival官方](https://www.cstr.ed.ac.uk/projects/festival/morevoices.html)  
    > 可以选择英音、美音、男声、女声

    > 其他操作系统
    - 需要确保安装了`nodejs`
    - 进入插件的`tts`目录运行`npm install`
        > 如果`install.sh`运行正常则自动安装，如果安装失败，请尝试手动安装

## Festival配置
> 仅针对`linux`用户说明
- 配置文件
    - 全局配置: `/usr/share/festival/siteinit.scm`
    - 用户配置: `~/.festivalrc`

- 更改声音
    - 在festival的voices文件内建立自己的文件夹
        > 一般其默认配置目录在`/usr/share/festival/voices`  

        示例:
        > `sudo mkdir /usr/share/festival/voices/my_voices`

    - 下载想要的voices文件并解压 
        > 正常均需要   

        - 试听[在这里](https://www.cstr.ed.ac.uk/projects/festival/morevoices.html))
        - 下载[在这里](http://festvox.org/packed/festival/2.5/voices/))
        > 假设下载的文件在`Downloads`文件夹, 下载的文件为:`festvox_cmu_us_aew_cg.tar.gz`

        示例:
        > `cd ~/Downloads && tar -xf festvox_cmu_us_aew_cg.tar.gz`

    - 将音频文件拷贝到festival文件夹
        示例:
        > `sudo cp -r festival/lib/voices/us/cmu_us_aew_cg/ /usr/share/festival/voices/my_voices/`

    - 在配置文件中设置默认的声音
        示例:
        > 加入`(set! voice_default voice_cmu_indic_hin_ab_cg)`到配置文件

    - 安装完成

- 相关说明网站
    > 正常均需要 
    - [wiki](https://archlinux.org/packages/community/any/festival-us/) 查看更多详细配置
    - [官方网站](http://festvox.org/dbs/index.html) 
    - [用户手册](http://www.festvox.org/docs/manual-2.4.0/festival_toc.html) 

## 配置
```lua
require'Trans'.setup {
    view = {
        i = 'float',
        n = 'hover',
        v = 'hover',
    },
    hover = {
        width = 37,
        height = 27,
        border = 'rounded',
        title = {
            { '', 'TransTitleRound' },
            { ' Trans', 'TransTitle' },
            { '', 'TransTitleRound' },
        },
        keymap = {
            -- TODO :
            pageup = '[[',
            pagedown = ']]',
            pin = '<leader>[',
            close = '<leader>]',
            toggle_entry = '<leader>;',
            play = '_',
        },
        animation = {
            -- open = 'fold',
            -- close = 'fold',
            open = 'slid',
            close = 'slid',
            interval = 12,
        },
        auto_close_events = {
            'InsertEnter',
            'CursorMoved',
            'BufLeave',
        },
        auto_play = true,
    },
    float = {
        width = 0.8,
        height = 0.8,
        border = 'rounded',
        title = {
            { '', 'TransTitleRound' },
            { ' Trans', 'TransTitle' },
            { '', 'TransTitleRound' },
        },
        keymap = {
            quit = 'q',
        },
        animation = {
            open = 'fold',
            close = 'fold',
            interval = 10,
        },
        tag = {
            wait = '#519aba',
            fail = '#e46876',
            success = '#10b981',
        },
        engine = {
            '本地',
        }
    },
    order = { -- only work on hover mode
        'title',
        'tag',
        'pos',
        'exchange',
        'translation',
        'definition',
    },
    icon = {
        star = '',
        notfound = ' ',
        yes = ' ',
        no = ''
        -- star = '⭐',
        -- notfound = '❔',
        -- yes = '✔️',
        -- no = '❌'
    },
    theme = 'default', -- 目前可选的: default, tokyonight, dracula
    db_path = '$HOME/.vim/dict/ultimate.db',

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
vim.keymap.set({'n', 'v'}, 'mm', '<Cmd>Translate<CR>')
vim.keymap.set('n', 'mi', '<Cmd>TranslateInput<CR>')

```

## 高亮组
> 默认定义
```lua
{
    TransWord = {
        fg = '#7ee787',
        bold = true,
    },
    TransPhonetic = {
        link = 'Linenr'
    },
    TransTitle = {
        fg = '#0f0f15',
        bg = '#75beff',
        bold = true,
    },
    TransTitleRound = {
        fg = '#75beff',
    },
    TransTag = {
        fg = '#e5c07b',
    },
    TransExchange = {
        link = 'TransTag',
    },
    TransPos = {
        link = 'TransTag',
    },
    TransTranslation = {
        link = 'TransWord',
    },
    TransDefinition = {
        link = 'Moremsg',
    },
    TransWin = {
        link = 'Normal',
    },
    TransBorder = {
        link = 'FloatBorder',
    },
    TransCollins = {
        fg = '#faf743',
        bold = true,
    },
    TransFailed = {
        fg = '#7aa89f',
    },
}
```
## 声明
- 本插件词典基于[ECDICT](https://github.com/skywind3000/ECDICT)

## 感谢
- [ECDICT](https://github.com/skywind3000/ECDICT)       本地词典的提供
- [sqlite.lua](https://github.com/kharji/sqlite.lua)    数据库访问
- [T.vim](https://github.com/sicong-li/T.vim)           灵感来源

## 待办 (画大饼)
- [x] 多风格样式查询
- [x] 重新录制屏幕截图示例 
- [ ] 历史查询结果保存
- [ ] 在线多引擎异步查询 
- [ ] 快捷键定义 
- [x] 自动读音 
- [ ] `句子翻译` | `中翻英` 的支持 
