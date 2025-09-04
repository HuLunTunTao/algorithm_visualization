图部分的使用方法


命令文档
格式：一行一命令；COMMAND key:value ...
值类型：
字符串：label:"Dijkstra step 1"（含空格请用引号）
布尔：true/false/1/0/on/off
颜色：#RRGGBB 或 #AARRGGBB
数值：123 或 3.14

命令一览：
命令	必填参数	可选参数	作用
INIT	-	-	清空图
RESET	-	-	同 INIT
ADD_NODE	id	label、color	添加节点
SET_LABEL	id、label	-	改节点标签
SET_COLOR	id、color	-	改节点颜色
HIGHLIGHT	id	on、color	高亮/取消高亮
SET_VISIT_ORDER	id、order	-（order 可缺省为清空）	设置访问序
ADD_EDGE	u、v	directed、color、weight	添加边
CLEAR_HIGHLIGHT	-	clearVisited	清除全部高亮，可选清访问序
LAYOUT	type	orientation	预留（当前不切换）

示例脚本：
INIT
ADD_NODE id:s label:"S" color:#3F51B5
ADD_NODE id:a label:"A" color:#009688
ADD_NODE id:b label:"B"
ADD_NODE id:t label:"T" color:#9C27B0
ADD_EDGE u:s v:a
ADD_EDGE u:s v:b
ADD_EDGE u:a v:t
ADD_EDGE u:b v:t
HIGHLIGHT id:s on:true color:#FFC107
SET_VISIT_ORDER id:s order:1
SET_VISIT_ORDER id:a order:2
SET_VISIT_ORDER id:t order:3