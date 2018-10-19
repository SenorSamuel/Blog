### Learning CSS

#### CSS 概述
- CSS 指层叠样式表 (Cascading Style Sheets)
- 样式定义**如何显示**HTML元素
- 样式通常存储在**样式表**中
- 把样式添加到 HTML 4.0 中，是为了**解决内容与表现分离的问题**
- **外部样式表**可以极大提高工作效率
- 外部样式表通常存储在**CSS文件**中
- 多个样式定义可**层叠**为一

一般而言，所有的样式会根据下面的规则层叠于一个新的虚拟样式表中，其中数字 4 拥有最高的优先权。

- 浏览器缺省设置
- 外部样式表
- 内部样式表（位于 <head> 标签内部）
- 内联样式（在 HTML 元素内部）

#### 1.CSS基础语法

```css
selector {declaration1; declaration2; ... declarationN }

selector {property: value; property: value; property: value}

h1 {color:red; font-size:14px;}

p { color: #ff0000; }

p {font-family: "sans serif";}

p {text-align:center; 
	color:red;
}	

body {
  color: #000;
  background: #fff;
  margin: 0;
  padding: 0;
  font-family: Georgia, Palatino, serif;
  }
  
与 XHTML 不同，CSS 对大小写不敏感。
不过存在一个例外：如果涉及到与 HTML 文档一起工作的话，class 和 id 名称对大小写是敏感的。

```

#### 2.高级语法
```css
h1,h2,h3,h4,h5,h6 {
  color: green;
  }

//body的所有子元素都使用这个字体
body {
     font-family: Verdana, sans-serif;
     }
     
 //重新设定一个规则,摆脱body的继承限制
 body  {
     font-family: Verdana, sans-serif;
     }

td, ul, ol, ul, li, dl, dt, dd  {
     font-family: Verdana, sans-serif;
     }

p  {
     font-family: Times, "Times New Roman", serif;
     }   
  

```

#### 3.高级选择器

```css
3.1 派生选择器 : 通过依据元素在其位置的上下文关系来定义样式，你可以使标记更加简洁。
l	i strong {
    font-style: italic;
    font-weight: normal;
}

strong {
     color: red;
}

h2 {
     color: red;
}

h2 strong {
     color: blue;
}

3.2 id 选择器 : id 选择器可以为标有特定 id 的 HTML 元素指定特定的样式。
#red {color:red;}
#green {color:green;}
下面的 HTML 代码中，id 属性为 red 的 p 元素显示为红色，而 id 属性为 green 的 p 元素显示为绿色。
<p id="red">这个段落是红色。</p>
<p id="green">这个段落是绿色。</p>

3.3 在现代布局中，id 选择器常常用于建立派生选择器。
上面的样式只会应用于出现在 id 是 sidebar 的元素内的段落。这个元素很可能是 div 或者是表格单元，尽管它也可能是一个表格或者其他块级元素。
#sidebar p {
	font-style: italic;
	text-align: right;
	margin-top: 0.5em;
	}

3.4 类选择器以一个点号显示
.center {text-align: center}
在下面的 HTML 代码中，h1 和 p 元素都有 center 类。这意味着两者都将遵守 ".center" 选择器中的规则。
<h1 class="center">This heading will be center-aligned</h1>
<p class="center">This paragraph will also be center-aligned.</p>

//div,table
.fancy td {
	color: #f60;
	background: #666;
}

//作用域td class = fancy的单元格
td.fancy {
	color: #f60;
	background: #666;
}

3.5 属性选择器
可以为拥有指定属性的 HTML 元素设置样式，而不仅限于 class 和 id 属性。
//下面的例子为带有 title 属性的所有元素设置样式：
[title]
{
color:red;
}

[title=W3School]
{
border:5px solid blue;
}

下面的例子为包含指定值的 title 属性的所有元素设置样式。适用于由空格分隔的属性值：
[title~=hello] { color:red; }

[lang|=en] { color:red; }

input[type="text"]
{
  width:150px;
  display:block;
  margin-bottom:10px;
  background-color:yellow;
  font-family: Verdana, Arial;
}

input[type="button"]
{
  width:120px;
  margin-left:35px;
  display:block;
  font-family: Verdana, Arial;
}


选择器	描述
[attribute]	用于选取带有指定属性的元素。
[attribute=value]	用于选取带有指定属性和值的元素。
[attribute~=value]	用于选取属性值中包含指定词汇的元素。
[attribute|=value]	用于选取带有以指定值开头的属性值的元素，该值必须是整个单词。
[attribute^=value]	匹配属性值以指定值开头的每个元素。
[attribute$=value]	匹配属性值以指定值结尾的每个元素。
[attribute*=value]	匹配属性值中包含指定值的每个元素。

```

#### 4. CSS样式语法
##### 背景
```css
事实上，所有背景属性都不能继承。
//4.1 背景色
p {background-color: gray; padding: 20px;}
//4.2 背景图像
body {background-image: url(/i/eg_bg_04.gif);}
//4.3 背景重复
body{ 
  background-image: url(/i/eg_bg_03.gif);
  background-repeat: repeat-y;//repeat-x,repeat-y,no-repeat
}
//4.4 背景定位
body{ 
background-image:url('/i/eg_bg_03.gif');
background-repeat:no-repeat;
background-position:center;
//background-position:50% 50%;
//background-position:50px 100px;
//background-position:top; ==	background-position:top center;
}

//4.5 背景关联  
body {
  background-image:url(/i/eg_bg_02.gif);
  background-repeat:no-repeat;
  background-attachment:fixed
}
```

##### 文字
```css
//4.6 缩进文本
p {text-indent: 5em;}
p {text-indent: -5em;}
p {text-indent: -5em; padding-left: 5em;}
//使用百分比值
div {width: 500px;}
p {text-indent: 20%;}
//继承 text-indent 属性可以继承，请考虑如下标记：
div#outer {width: 500px;}
div#inner {text-indent: 10%;}
p {width: 200px;}


//4.7 水平对齐
text-align 是一个基本的属性，它会影响一个元素中的文本行互相之间的对齐方式。
left、right 和 center justify

//4.8 字间隔 
p.spread {word-spacing: 30px;}
p.tight {word-spacing: -0.5em;}

<p class="spread">
This is a paragraph. The spaces between words will be increased.
</p>

<p class="tight">
This is a paragraph. The spaces between words will be decreased.
</p>

//4.9 字母间隔
h1 {letter-spacing: -0.5em}
h4 {letter-spacing: 20px}

<h1>This is header 1</h1>
<h4>This is header 4</h4>

//4.10 字符转换
h1 {text-transform: uppercase}

// 4.11 文本装饰: text-decoration 值会替换而不是累积起来。
text-decoration 有 5 个值：
none
underline
overline
line-through
blink

h2.stricken {text-decoration: line-through;}
h2 {text-decoration: underline overline;}

//4.12 处理空白符
white-space 属性会影响到用户代理对源文档中的空格、换行和 tab 字符的处理。
值			空白符		换行符		自动换行
pre-line	合并		保留			允许
normal		合并		忽略			允许
nowrap		合并		忽略			不允许
pre			保留	    保留			不允许
pre-wrap	保留		保留			允许


//4.13 文字方向
direction 属性影响块级元素中文本的书写方向、表中列布局的方向、内容水平填充其元素框的方向、以及两端对齐元素中最后一行的位置。
注释：对于行内元素，只有当 unicode-bidi 属性设置为 embed 或 bidi-override 时才会应用 direction 属性。

//其他
body {color:red}
span.highlight{ background-color:yellow}
p.small {line-height: 90%} //在大多数浏览器中默认行高大约是 110% 到 120%。
p.small {line-height: 10px} //在大多数浏览器中默认行高大约是 20px。
p.big{line-height: 2}		//默认行高大约是 1。
```

#### 字体

```css
//4.14 指定字体系列
通用字体系列 - 拥有相似外观的字体系统组合（比如 Serif,Monospace,Sans-serif,Cursive,Fantasy ）
特定字体系列 - 具体的字体系列（比如 "Times" 或 "Courier"）
body {font-family: sans-serif;}

h1 {font-family: Georgia;}

h1 {font-family: Georgia, serif;}

//字体名中有一个或多个空格（比如 New York），或者如果字体名包括 # 或 $ 之类的符号，才需要在 font-family 声明中加引号
p {font-family: Times, TimesNR, 'New Century Schoolbook',Georgia, 'New York', serif;}

//4.15 字体风格
该属性有三个值：
normal - 文本正常显示
italic - 文本斜体显示
oblique - 文本倾斜显示
p.normal {font-style:normal;}
p.italic {font-style:italic;}
p.oblique {font-style:oblique;}

//4.16 字体变形
小型大写字母不是一般的大写字母，也不是小写字母，这种字母采用不同大小的大写字母。
p {font-variant:small-caps;}

//4.17 字体加粗
关键字 100 ~ 900 为字体指定了 9 级加粗度。如果一个字体内置了这些加粗级别，那么这些数字就直接映射到预定义的级别，100 对应最细的字体变形，900 对应最粗的字体变形。数字 400 等价于 normal，而 700 等价于 bold。
p.normal {font-weight:normal;}
p.thick {font-weight:bold;}
p.thicker {font-weight:900;}


//4.18 字体大小
h1 {font-size:60px;}
h2 {font-size:40px;}
p {font-size:14px;}
//if basefont == 16px
h1 {font-size:3.75em;} /* 60px/16=3.75em */
h2 {font-size:2.5em;}  /* 40px/16=2.5em */
p {font-size:0.875em;} /* 14px/16=0.875em */


//4.19 设置链接的样式
//能够设置链接样式的 CSS 属性有很多种（例如 color, font-family, background 等等）。
链接的四种状态：
a:link - 普通的、未被访问的链接
a:visited - 用户已访问的链接
a:hover - 鼠标指针位于链接的上方
a:active - 链接被点击的时刻

当为链接的不同状态设置样式时，请按照以下次序规则：
- a:hover 必须位于 a:link 和 a:visited 之后
- a:active 必须位于 a:hover 之后

//4.20 CSS 列表属性允许你放置、改变列表项标志，或者将图像作为列表项标志。
ul {list-style-type : square}
ul li {list-style-image : url(xxx.gif)}
li {list-style : url(example.gif) square inside}


//4.21 CSS 表格
table, th, td {border: 1px solid blue;}
table{border-collapse:collapse;}
table{width:100%;}
th{height:50px;}
td{text-align:right;}
td{
 height:50px;
 vertical-align:bottom;
}

td{padding:15px;}
th{background-color:green;color:white;}

```

### 五.CSS 框模型概述
![SamuelChan/20180828191728.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180828191728.png)

背景应用于由内容和内边距、边框组成的区域。
内边距、边框和外边距都是可选的，默认值是零

```css
box {
  width: 70px;
  margin: 10px;
  padding: 5px;
}

提示：内边距、边框和外边距可以应用于一个元素的所有边，也可以应用于单独的边。
提示：外边距可以是负值，而且在很多情况下都要使用负值的外边距。

CSS padding 属性定义元素的内边距。padding 属性接受长度值或百分比值，但不允许使用负值。
h1 {padding: 10px;}
h1 {padding: 10px 0.25em 2ex 20%;}

h1 {
  padding-top: 10px;
  padding-right: 0.25em;
  padding-bottom: 2ex;
  padding-left: 20%;
}

//百分数值是相对于其父元素的 width 计算的，这一点与外边距一样。所以，如果父元素的 width 改变，它们也会改变。
//注意：上下内边距与左右内边距一致；即上下内边距的百分数会相对于父元素宽度设置，而不是相对于高度。
p {padding: 10%;}

```

#### 边框

```css
每个边框有 3 个方面：宽度、样式，以及颜色。
a:link img {border-style: outset;}
p.aside {border-style: solid dotted dashed double;}

//您可以按照 top-right-bottom-left 的顺序设置元素的各边边框：
p {border-style: solid; border-width: 5px;}
p {border-style: solid; border-width: 15px 5px 15px 5px;}

p {
  border-style: solid;
  border-color: blue rgb(25%,35%,45%) #909090 red;
}

img 
{
float:right;
border:1px dotted black; //宽度,点样式,黑色
margin:0px 0px 15px 20px;
}

```

#### 外边距

```css
h1 {margin : 10px 0px 15px 5px;}

p {margin : 10%;}

h1 {margin: 0.25em 1em 0.5em;}	/* 等价于 0.25em 1em 0.5em 1em */
h2 {margin: 0.5em 1em;}		/* 等价于 0.5em 1em 0.5em 1em */
p {margin: 1px;}			/* 等价于 1px 1px 1px 1px */

h2 {
  margin-top: 20px;
  margin-right: 30px;
  margin-bottom: 30px;
  margin-left: 20px;
  }
  
```

#### 外边距合并
当一个元素出现在另一个元素上面时，第一个元素的下外边距与第二个元素的上外边距会发生合并。请看下图：
![](http://www.w3school.com.cn/i/ct_css_margin_collapsing_example_1.gif)
当一个元素包含在另一个元素中时（假设没有内边距或边框把外边距分隔开），它们的上和/或下外边距也会发生合并。请看下图：
![](http://www.w3school.com.cn/i/ct_css_margin_collapsing_example_2.gif)

注释：只有普通文档流中块框的垂直外边距才会发生外边距合并。**行内框、浮动框**或**绝对定位**之间的外边距不会合并。

### 六.CSS 定位 (Positioning)

div、h1 或 p 元素常常被称为块级元素。这意味着这些元素显示为一块内容，即“块框”。与之相反，span 和 strong 等元素称为“行内元素”，这是因为它们的内容显示在行中，即“行内框”。
您可以使用 display 属性改变生成的框的类型。这意味着，通过将 display 属性设置为 block，可以让行内元素（比如\<a> 元素）表现得像块级元素一样。还可以通过把 display 设置为 none，让生成的元素根本没有框。这样的话，该框及其所有内容就不再显示，不占用文档中的空间。
但是在一种情况下，即使没有进行显式定义，也会创建块级元素。这种情况发生在把一些文本添加到一个块级元素（比如 div）的开头。即使没有把这些文本定义为段落，它也会被当作段落对待：

```
<div>
some text
<p>Some more text.</p>
</div>
```


```css
div 
{
background-color:#00FFFF;
width:150px;
height:150px;
overflow: scroll;
//overflow: hidden
//overflow: auto
}

//本例演示如何设置元素的形状。此元素被剪裁到这个形状内，并显示出来。
img 
{
position:absolute;
clip:rect(0px 50px 200px 0px)
}

//本例演示如何在文本中垂直排列图象。
img.top {vertical-align:text-top}
img.bottom {vertical-align:text-bottom}

```

#### CSS 定位和浮动
CSS 有三种基本的定位机制：普通流、浮动和绝对定位。
除非专门指定，否则所有框都在**普通流**中定位。也就是说，普通流中的元素的位置由元素在 (X)HTML 中的位置决定。
块级框从上到下一个接一个地排列，框之间的垂直距离是由框的垂直外边距计算出来。
**行内框**在一行中水平布置。可以使用水平内边距、边框和外边距调整它们的间距。但是，垂直内边距、边框和外边距不影响行内框的高度。由一行形成的水平框称为**行框**（Line Box），`行框的高度总是足以容纳它包含的所有行内框。不过，设置行高可以增加这个框的高度。`

**绝对定位**

设置为绝对定位的元素框从文档流完全删除，并相对于其包含块定位，包含块可能是文档中的另一个元素或者是初始包含块。元素原先在正常文档流中所占的空间会关闭，就好像该元素原来不存在一样。元素定位后生成一个块级框，而不论原来它在正常流中生成何种类型的框。

**浮动**

**浮动的框可以向左或向右移动，直到它的外边缘碰到包含框或另一个浮动框的边框为止。
由于浮动框不在文档的普通流中，所以文档的普通流中的块框表现得就像浮动框不存在一样。**

块浮动

![](http://www.w3school.com.cn/i/ct_css_positioning_floating_right_example.gif)

![](http://www.w3school.com.cn/i/ct_css_positioning_floating_left_example.gif)

![](http://www.w3school.com.cn/i/ct_css_positioning_floating_left_example_2.gif)


```css
//example
<html>
<head>
<style type="text/css">
div.container
{
width:100%;
margin:0px;
border:1px solid gray;
line-height:150%;
}
div.header,div.footer
{
padding:0.5em;
color:white;
background-color:gray;
clear:left;
}
h1.header
{
padding:0;
margin:0;
}
div.left
{
float:left;
width:160px;
margin:0;
padding:1em;
}
div.content
{
margin-left:190px;
border-left:1px solid gray;
padding:1em;
}
</style>
</head>
<body>

<div class="container">

<div class="header"><h1 class="header">W3School.com.cn</h1></div>

<div class="left"><p>"Never increase, beyond what is necessary, the number of entities required to explain anything." William of Ockham (1285-1349)</p></div>

<div class="content">
<h2>Free Web Building Tutorials</h2>
<p>At W3School.com.cn you will find all the Web-building tutorials you need,
from basic HTML and XHTML to advanced XML, XSL, Multimedia and WAP.</p>
<p>W3School.com.cn - The Largest Web Developers Site On The Net!</p></div>

<div class="footer">Copyright 2008 by YingKe Investment.</div>

</div>

</body>
</html>
	
```

### CSS 选择器

####多类选择器
```css
<p class="important warning">
This paragraph is a very important warning.
</p>

.important {font-weight:bold;}
.warning {font-style:italic;}
.important.warning {background:silver;}

```

#### 类选择器还是 ID 选择器？
在类选择器这一章中我们曾讲解过，可以为任意多个元素指定类。前一章中类名 important 被应用到 p 和 h1 元素，而且它还可以应用到更多元素。

**区别 1：只能在文档中使用一次**
与类不同，在一个 HTML 文档中，ID 选择器会使用一次，而且仅一次。

**区别 2：不能使用 ID 词列表**
不同于类选择器，ID 选择器不能结合使用，因为 ID 属性不允许有以空格分隔的词列表。

**区别 3：ID 能包含更多含义**

类似于类，可以独立于元素来选择 ID。有些情况下，您知道文档中会出现某个特定 ID 值，但是并不知道它会出现在哪个元素上，所以您想声明独立的 ID 选择器。例如，您可能知道在一个给定的文档中会有一个 ID 值为 mostImportant 的元素。您不知道这个最重要的东西是一个段落、一个短语、一个列表项还是一个小节标题。您只知道每个文档都会有这么一个最重要的内容，它可能在任何元素中，而且只能出现一个。在这种情况下，可以编写如下规则：


#### 后代选择器
后代选择器（descendant selector）又称为包含选择器。后代选择器可以选择作为某元素后代的元素。

举例来说，如果您希望只对 h1 元素中的 em 元素应用样式，可以这样写：

```css
上面这个规则会把作为 h1 元素后代的 em 元素的文本变为 红色。其他 em 文本（如段落或块引用中的 em）则不会被这个规则选中：
h1 em 选择器可以解释为 “作为 h1 元素后代的任何 em 元素”
h1 em {color:red;}


如果写作 ul em，这个语法就会选择从 ul 元素继承的所有 em 元素，而不论 em 的嵌套层次多深。
```

#### 子元素选择器

```css
如果您不希望选择任意的后代元素，而是希望缩小范围，只选择某个元素的子元素，请使用子元素选择器（Child selector）。
例如，如果您希望选择只作为 h1 元素子元素的 strong 元素，可以这样写：
h1 > strong {color:red;}


table.company td > p
上面的选择器会选择作为 td 元素子元素的所有 p 元素，这个 td 元素本身从 table 元素继承，该 table 元素有一个包含 company 的 class 属性。

```

#### 相邻兄弟选择器（Adjacent sibling selector）可选择紧接在另一元素后的元素，且二者有相同父元素。

```css
h1 + p {margin-top:50px;}

“选择紧接在 h1 元素后出现的段落，h1 和 p 元素拥有共同的父元素,将margin-top:50px作用在p标签上面”。
```

#### 伪类

```css
伪类的语法：
selector : pseudo-class {property: value}

CSS 类也可与伪类搭配使用。
selector.class : pseudo-class {property: value}


锚伪类
a:link {color: #FF0000}		/* 未访问的链接 */
a:visited {color: #00FF00}	/* 已访问的链接 */
a:hover {color: #FF00FF}	/* 鼠标移动到链接上 */
a:active {color: #0000FF}	/* 选定的链接 */


p:first-child {font-weight: bold;}//第一个规则将作为某元素第一个子元素的所有 p 元素设置为粗体。
li:first-child {text-transform:uppercase;}//第二个规则将作为某个元素（在 HTML 中，这肯定是 ol 或 ul 元素）第一个子元素的所有 li 元素变成大写。

伪元素
:first-letter	向文本的第一个字母添加特殊样式
:first-line	向文本的首行添加特殊样式。	
:before	在元素之前添加内容。	
:after	在元素之后添加内容。	

```