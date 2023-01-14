# 字段说明

## 本地
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

## 有道
### 中英

basic	JSONObject	简明释义
phonetic	text	词典音标
usPhonetic	text	美式音标
ukPhonetic	text	英式音标
ukSpeech	text	英式发音
usSpeech	text	美式发音
explains	text	基本释义
text	text	短语
explain	String Array	词义解释列表
wordFormats	Object Array	单词形式变化列表
name	String	形式名称，例如：复数
web	JSONArray	网络释义
phrase	String	词组
meaning	String	含义
synonyms	JSONObject	近义词
pos	String	词性
words	String Array	近义词列表
trans	String	释义
antonyms	ObjectArray	反义词
relatedWords	JSONArray	相关词
wordNet	JSONObject	汉语词典网络释义
phonetic	String	发音
meanings	ObjectArray	释义
meaning	String	释义
example	array	示例
dict	String	词典deeplink
webDict	String	词典网页deeplink
sentenceSample	text	例句
sentence	text	例句
sentenceBold	text	将查询内容加粗的例句
translation	text	例句翻译
wfs	text	单词形式变化
exam_type	text	考试类型

## 百度
from	string	源语言	返回用户指定的语言，或者自动检测出的语种（源语言设为auto时）
to	string	目标语言	返回用户指定的目标语言
trans_result	array	翻译结果	返回翻译结果，包括src和dst字段
trans_result.*.src	string	原文	接入举例中的“apple”
trans_result.*dst	string	译文	接入举例中的“苹果”
error_code	integer	错误码	仅当出现错误时显示
以下字段仅开通了词典、tts用户可见
src_tts	string	原文tts链接	mp3格式，暂时无法指定发音
dst_tts	string	译文tts链接	mp3格式，暂时无法指定发音
dict	string	中英词典资源	返回中文或英文词典资源，包含音标；简明释义等内容

### 返回结果
- 英-> 中
```json
{
    "from": "en", 
    "to": "zh", 
    "trans_result": [
        {
            "src": "apple", 
            "dst": "苹果"
        }
    ]
}
```
- 中->英
```json
{
    "from": "zh", 
    "to": "en", 
    "trans_result": [
        {
            "src": "中国", 
            "dst": "China"
        }
    ]
}
```
## 彩云小译
句子翻译
> sh xiaoyi.sh en2zh "You know some birds are not meant to be caged, their feathers are just too bright."
> 你知道有些鸟不应该被关在笼子里，它们的羽毛太亮了。

## 必应

## 腾讯翻译君

