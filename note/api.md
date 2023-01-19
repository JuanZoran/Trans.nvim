# API说明

<!--toc:start-->
- [API说明](#api说明)
  - [数据结构](#数据结构)
    - [翻译](#翻译)
    - [窗口](#窗口)
    - [翻译结果](#翻译结果)
    - [内容单位](#内容单位)
- [窗口绘制逻辑](#窗口绘制逻辑)
  - [hover](#hover)
  - [float](#float)
<!--toc:end-->

## 数据结构

### 翻译
- `word`  
待翻译的字符串: string
- `sentence`  
是否为句子: boolean
- `result`  
翻译查询的结果: table
    > 见: [翻译结果](#翻译结果) 
- `engine`  

### 窗口
- `style`  
风格: string
- `height`  
高度: integer
- `width`  
宽度: integer
- `border`  
边框样式: string
- `winhl`  
窗口的高亮: string

### 翻译结果
**无特殊说明, 所有字段均为`string`类型** 

- `word`  
查询的字符串
- `phonetic`  
音标
- `collins`  
柯林斯星级: integer
- `oxford` 
是否为牛津词汇: integer (1为是)
- `tag`  
标签
- `pos`  
词性
- `exchange`  
词态变化
- `translation`  
中文翻译
- `definition`  
英文注释


### 内容单位
- `field` 字段
    > 是展示的最小单位  

    **属性**
    - `1`
    存储的文本: string
    - `2`  (optional)
    对应的高亮: string
    - `_start`  
    起始行: integer
    - `_end`  
    结束行: integer
    > **注意:** `_start` 和`_end` 字段只有已经被展示到窗口后才会被设置  

    **方法** 
    - 无 

- `line` 行
    > 窗口展示的每一行, 一个行有多个`field`

    **属性**
    - `text`  
    当前保存的字符串: string
    - `hls`  
    行内的高亮: table
    - `index`  
    行号[0为起始下标]
    - `fields`  
    行内保存的`field`
    - `status`  
    行内是否需要更新: boolean
    > **注意:** `num` 只有已经被展示到窗口后才会被设置

    **方法** 
    - `update`  
    更新`text`和`hls`
    - `data`  
    获取行的text
    - `insert`  
    添加新`field`
    - `add_highlight`  
    添加高亮
        > 参数: bufnr

- `content` 内容
    > 窗口展示的单位, 一个内容内有多个`line`
    
    **方法** 
    - `data`  
    返回lines和highlights
    - `insert` 
    插入新的行
    - `attach`  
    将内容展示到buffer
        > 参数: bufnr

# 窗口绘制逻辑

- 获取所有组件
## hover
- 按照order顺序加载
- 按组件间距为4计算组件个数能否在一行以内放下
    - 放不下则按照组件间距为4 计算组件个数并对齐
    - 放得下则重新计算组间距

获得组件行内容, 设置到行内
获取组件高亮, 设置高亮

## float
由定义好的逻辑，绘制整个窗口
