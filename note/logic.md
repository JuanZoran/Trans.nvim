# 命令说明

<!--toc:start-->
- [命令说明](#命令说明)
  - [Translate](#translate)
  - [TranslateInput](#translateinput)
  - [TranslateHistory](#translatehistory)
  - [自定义](#自定义)
    - [可选项说明](#可选项说明)
    - [示例](#示例)
<!--toc:end-->

## Translate
**窗口风格默认为:** `cursor`
- 动作(action):
    - `vsplit`         水平分屏
    - `split`          垂直分屏
    - `float`          窗口样式又`cursor` 变为`float`
    - `online_query`   使用在线引擎重新进行查询
    - `history_insert` 将此次查询的单词记录到历史记录  
    - `next`           展示下一个引擎的查询结果(如果默认设置了多个引擎)
    - `prev`           展示上一个查询结果
    > 如果没有设置自动保存历史的话

    - `history`        查看历史查询的记录

- `online_query`:
    - `local_add`    将此次查询的结果添加到本地数据库  
    > **如果本地已经存在该单词，会询问是否需要覆盖掉相同的字段**

    - `local_update` 和*local_add* 类似, 但是不会询问是否覆盖
    - `diff`         对比本地查询结果和此次在线查询的区别

>  **注意**: 动作是任何窗口通用的  
## TranslateInput
**窗口风格默认为:** `float`
- 自行得到要查询的单词

- TODO: 
    - fuzzy match

## TranslateHistory
**窗口风格默认为:** `float`
- 查看历史查询

---
## 自定义

### 可选项说明
- 查询方式(method): `string`
    - `input` 自行输入需要查询的单词
    - `last`  显示上一次查询的结果
    - `history`

- 查询引擎(engine): `string | table`
    - `offline` 离线的数据库
    - `youcao` 有道api
    - `baidu` 百度api
    - `google` 谷歌api
    - `bing` 必应api
    - `iciba` 金山词霸api
    - `xunfei` 讯飞api

- 窗口风格(win): `string | table`
    - 样式(style): 
        - `cursor` 在光标附近弹出
        - `float` 悬浮窗口
        - `split` 在上方或者下方分屏
        - `vsplit` 在左边或者右边分屏

    - 高度(height):
        - `value > 1` 最大高度
        - `0 <= value <= 1` 相对高度
        - `0 < value` 无限制

    - 宽度(width):
        > 和`高度(height)`相同
### 示例
```lua
vim.keymap.set('n', 'mi', function ()
    require('Trans').translate({
        method = 'input', -- 不填则自动判断mode获取查询的单词
        engine = { -- 异步查询所有的引擎, 按照列表
            'offline',
            'youdao',
            'baidu'
        },
        -- win = 'cursor'
        win = {
            style = 'cursor',
            height = 50,
            width = 30,
        }
    })
end, { desc = '在光标旁弹出输入的单词释义'})
```
