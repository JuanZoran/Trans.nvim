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
