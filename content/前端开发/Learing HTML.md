### Learing HTML

#### 1.本地测试httpServer
- python SimpleHttpServer : localhost:8000
	- python -V(mac自带python)
	- If Python version returned above is 3.X
		
		> python -m http.server port(默认8000)
	 
	  If Python version returned above is 2.X
		
		> python -m SimpleHTTPServer port(默认8000)

- mac自带apache
	> $ sudo apachectl start
	
	
	
#### 2.目录结构
- `index.html`: This file will generally contain your homepage content, that is, the text and images that people see when they first go to your site. Using your text editor, create a new file called index.html and save it just inside your test-site folder.
- `images folder`: This folder will contain all the images that you use on your site. Create a folder called images, inside your test-site folder.
- `styles folder`: This folder will contain the CSS code used to style your content (for example, setting text and background colors). Create a folder called styles, inside your test-site folder.
- `scripts folder`: This folder will contain all the JavaScript code used to add interactive functionality to your site (e.g. buttons that load data when clicked). Create a folder called scripts, inside your test-site folder.

#### 3.HTML语法
![SamuelChan/20180824120244.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180824120244.png)
The main parts of our element are:

- **The opening tag**: This consists of the name of the element (in this case, p), wrapped in opening and closing angle brackets. This states where the element begins, or starts to take effect — in this case where the paragraph begins.
- **The closing tag**: This is the same as the opening tag, except that it includes a forward slash before the element name. This states where the element ends — in this case where the end of the paragraph is. Failing to include a closing tag is one of the common beginner errors and can lead to strange results.
- **The content**: This is the content of the element, which in this case is just text.
- **The element**: The opening tag, the closing tag, and the content together comprise the element.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>My test page</title>
  </head>
  <body>
    <img src="images/firefox-icon.png" alt="My test image">
  </body>
</html>

<!DOCTYPE html> — the doctype. In the mists of time, when HTML was young (about 1991/2), doctypes were meant to act as links to a set of rules that the HTML page had to follow to be considered good HTML, which could mean automatic error checking and other useful things. However, these days no one really cares about them, and they are really just a historical artifact that needs to be included for everything to work right. For now, that's all you need to know.

<html></html> — the <html> element. This element wraps all the content on the entire page, and is sometimes known as the root element.

<head></head> — the <head> element. This element acts as a container for all the stuff you want to include on the HTML page that isn't the content you are showing to your page's viewers. This includes things like keywords and a page description that you want to appear in search results, CSS to style our content, character set declarations, and more.

<meta charset="utf-8"> — this element sets the character set your document should use to UTF-8, which includes most characters from the vast majority of human written languages. Essentially it can now handle any textual content you might put on it. There is no reason not to set this, and it can help avoid some problems later on.

<title></title> — the <title> element. This sets the title of your page, which is the title that appears in the browser tab the page is loaded in. It is also used to describe the page when you bookmark/favourite it.

<body></body> — the <body> element. This contains all the content that you want to show to web users when they visit your page, whether that's text, images, videos, games, playable audio tracks, or whatever else.

```

### HTML 文档 = 网页

- HTML 文档描述网页
- HTML 文档包含 HTML 标签和纯文本
- HTML 文档也被称为网页

```html
<html>
<body>
<h1>我的第一个标题</h1>
<p>我的第一个段落。</p>
</body>
</html>
```
`<html>` 与 `</html>` 之间的文本描述网页

`<body>` 与 `</body>` 之间的文本是可见的页面内容

`<h1>` 与 `</h1>` 之间的文本被显示为标题

`<p>` 与 `</p>` 之间的文本被显示为段落

### 语法

#### 1.标题 
```html
//默认情况下，HTML 会自动地在块级元素前后添加一个额外的空行，比如段落、标题元素前后。
<h1>This is heading 1</h1>
<h2>This is heading 2</h2>
<h3>This is heading 3</h3>
<h4>This is heading 4</h4>
<h5>This is heading 5</h5>
<h6>This is heading 6</h6>

请仅仅把标题标签用于标题文本。不要仅仅为了产生粗体文本而使用它们。请使用其它标签或 CSS 代替。

<hr/>:标签在 HTML 页面中创建水平线,可用于分隔内容。
```

#### 2.段落
```html
<p>This is another paragraph.</p>
//如果您希望在不产生一个新段落的情况下进行换行（新行），请使用<br/>标签
<p>This is<br />a para<br />graph with line breaks</p>

<div style="color:#00FF00">
  <h3>This is a header</h3>
  <p>This is a paragraph.</p>
</div>

//<span> 标签被用来组合文档中的行内元素。
<p><span>some text.</span>some other text.</p>
```

#### 3.链接
```html
<a href="http://www.w3school.com.cn">This is a link</a>
//3.1在新窗口打开
<a href="http://www.w3school.com.cn/" target="_blank">Visit W3School!</a>
//3.2用a标签的name属性在本页面跳转
<a href="#C4">查看 Chapter 4。</a>
<h2><a name="C4">Chapter 4</a></h2>
```

#### 4.图像
```html
<img src="w3school.jpg" width="104" height="142" />

//HTML元素以开始标签起始,以结束标签终止
//元素的内容是开始标签与结束标签之间的内容
//某些 HTML 元素具有空内容（empty content
//空元素在开始标签中进行关闭（以开始标签的结束而结束）<br/>,<img src="xxx"/>
//大多数 HTML 元素可拥有属性
//大小写敏感
```

#### 5.标签属性
```html
<h1 align="center"> 	//style 属性淘汰了旧的 "align" 属性。
<body bgcolor="yellow">//style 属性淘汰了“旧的” bgcolor 属性。
<table border="1">	//废弃
style 属性淘汰了旧的 <font> 标签。

//style属性"直接"将样式添加到 HTML 元素，或者"间接"地在独立的样式表中（CSS 文件）进行定义。
<body style="background-color:yellow">
<h1 style="font-family:verdana">A heading</h1>
<p style="font-family:arial;color:red;font-size:20px;">A paragraph.</p>
<h1 style="text-align:center">This is a heading</h1>

下面列出了适用于大多数 HTML 元素的属性：
属性		值					  描述
class	classname			规定元素的类名（classname）
id		id					规定元素的唯一 id
style	style_definition	规定元素的行内样式（inline style）
title	text				规定元素的额外信息（可在工具提示中显示）
```

#### 6.注释
```html
<!DOCTYPE html>
<!-- This is a comment -->
```


#### 7.HTML 文本格式化
```html
//文本格式化
<b>This text is bold</b>

<strong>This text is strong</strong>

<pre>
这是
预格式文本。
它保留了      空格
和换行。
</pre>

<code>Computer code</code>
<br />
<kbd>Keyboard input</kbd>
<br />
<tt>Teletype text</tt>
<br />
<samp>Sample text</samp>
<br />
<var>Computer variable</var>
<br />

//地址
<address>
Written by <a href="mailto:webmaster@example.com">Donald Duck</a>.<br> 
Visit us at:<br>
Example.com<br>
Box 564, Disneyland<br>
USA
</address>

//文字方向
<bdo dir="rtl">
Here is some Hebrew text
</bdo>

//引用
<blockquote>
这是长的引用。这是长的引用。这是长的引用。这是长的引用。这是长的引用。这是长的引用。这是长的引用。这是长的引用。这是长的引用。这是长的引用。这是长的引用。
</blockquote>
<q>这是短的引用。</q>

//删除线,下划线
<p>一打有 <del>二十</del> <ins>十二</ins> 件。</p>

//用于缩略词的 HTML <abbr>:对缩写进行标记能够为浏览器、翻译系统以及搜索引擎提供有用的信息。
<p><abbr title="World Health Organization">WHO</abbr> 成立于 1948 年。</p>
```


#### 8.HTML CSS
```html

//8.1 外部样式表: 当样式需要被应用到很多页面的时候，外部样式表将是理想的选择
<head><link rel="stylesheet" type="text/css" href="mystyle.css"></head>
//8.2 内部样式表: 当单个文件需要特别样式时，就可以使用内部样式表。
<head>
<style type="text/css">body {background-color: red} p {margin-left: 20px}</style>
</head>
//8.3 内联样式表:当特殊的样式需要应用到个别元素时，就可以使用内联样式。 
<p style="color: red; margin-left: 20px">This is a paragraph</p>
```

#### 9.图像
```html

<img src="/i/eg_mouse.jpg" width="128" height="128" />

<img src="http://www.w3school.com.cn/i/w3school_logo_white.gif" />

//alt 属性用来为图像定义一串预备的可替换的文本。替换文本属性的值是用户定义的。
<img src="boat.gif" alt="Big Boat">

//背景图片
<body background="/i/eg_background.jpg">

//如何在文字中排列图像. 默认是bottom
<p>图像 <img src="/i/eg_cute.gif" align="bottom"> 在文本中</p>
<p>图像 <img src ="/i/eg_cute.gif" align="middle"> 在文本中</p>
<p>图像 <img src ="/i/eg_cute.gif" align="top"> 在文本中</p>

//浮动方式
<p><img src ="/i/eg_cute.gif" align ="left"> 带有图像的一个段落。图像的 align 属性设置为 "left"。图像将浮动到文本的左侧。</p>
<p><img src ="/i/eg_cute.gif" align ="right"> 带有图像的一个段落。图像的 align 属性设置为 "right"。图像将浮动到文本的右侧。</p>

//图片大小
<img src="/i/eg_mouse.jpg" width="200" height="200">

//您也可以把图像作为链接来使用：
<a href="/example/html/lastpage.html">
<img border="0" src="/i/eg_buttonnext.gif" />
</a>
```


#### 10.表格
```html

<table border="1">
<tr> 				
  <th>姓名</th>//表头
  <th>电话</th>
  <th>电话</th>
</tr>

<tr>//行
  <td>100</td>//格
  <td>200</td>
  <td>300</td>
</tr>
<tr>
  <td>400</td>
  <td>500</td>
  <td>600</td>
</tr>
</table>

//<caption>我的标题</caption>
//横跨两行的单元格
<th colspan="2">电话</th>

//纵跨两行的单元格
<th rowspan="2">电话</th>

//Cell padding 来创建单元格内容与其边框之间的空白。
<table border="1" cellpadding="10">...</table>

//Cell spacing 增加单元格之间的距离
<table border="1" spacing ="10">...</table>

//表格背景颜色
<table border="1" bgcolor="red">

//背景图像
<table border="1" background="/i/eg_bg_07.gif">

//"align" 属性排列单元格内容,以便创建一个美观的表格。
<td align="left">化妆品</td>

//"frame" 属性来控制围绕表格的边框。
<table frame="box">
  <tr>
    <th>Month</th>
    <th>Savings</th>
  </tr>
  <tr>
    <td>January</td>
    <td>$100</td>
  </tr>
</table>
```

#### 11.列表
```html

//无序列表
<ul>
<li>Coffee</li>
<li>Milk</li>
</ul>
//有序列表
<ol>
<li>Coffee</li>
<li>Milk</li>
</ol>

//
<ul type="disc">
<ul type="circle">
<ul type="square">
<ol type="A">
<ol type="a">
<ol type="I">
<ol type="i">
```

#### 12.\<div> 和 \<span>

```html
块级元素在浏览器显示时，通常会以新行来开始（和结束）: 例子：<h1>, <p>, <ul>, <table>
内联元素在显示时通常不会以新行开始。: 例子：<b>, <td>, <a>, <img>
//<div> 元素:<div> 元素是块级元素，它是可用于组合其他 HTML 元素的容器。
//HTML <span> 元素是内联元素，可用作文本的容器。当与 CSS 一同使用时，<span> 元素可用于为部分文本设置样式属性。
```

#### 13.HTML类使我们能够为元素的类定义 CSS 样式。

```html

为相同的类设置相同的样式
或者为不同的类设置不同的样式。
<!DOCTYPE html>
<html>
<head>
<style>
.cities {
    background-color:black;
    color:white;
    margin:20px;
    padding:20px;
} 
</style>
</head>

<body>
<div class="cities">
<h2>London</h2>
<p>
London is the capital city of England. 
It is the most populous city in the United Kingdom, 
with a metropolitan area of over 13 million inhabitants.
</p>
</div> 
</body>
</html>

<!DOCTYPE html>
<html>
<head>
<style>
  span.red {color:red;}
</style>
</head>
<body>
<h1>My <span class="red">Important</span> Heading</h1>
</body>
</html>

```

#### 14.HTML 布局

```html
<head>
<style>
#header {
    background-color:black;
    color:white;
    text-align:center;
    padding:5px;
}
#nav {
    line-height:30px;
    background-color:#eeeeee;
    height:300px;
    width:100px;
    float:left;
    padding:5px; 
}
#section {v
    width:350px;
    float:left;
    padding:10px; 
}
#footer {
    background-color:black;
    color:white;
    clear:both;
    text-align:center;
    padding:5px; 
}
</style>

</head>

<body>

<div id="header">
<h1>City Gallery</h1>
</div>

<div id="nav">
London<br>
Paris<br>
Tokyo<br>
</div>

<div id="section">
<h1>London</h1>
<p>
London is the capital city of England. It is the most populous city in the United Kingdom,
with a metropolitan area of over 13 million inhabitants.
</p>
<p>
Standing on the River Thames, London has been a major settlement for two millennia,
its history going back to its founding by the Romans, who named it Londinium.
</p>
</div>

<div id="footer">
Copyright W3School.com.cn
</div>

</body>

```

#### 15.什么是响应式 Web 设计？
```html

RWD 指的是响应式 Web 设计（Responsive Web Design）
RWD 能够以可变尺寸传递网页
RWD 对于平板和移动设备是必需的

//1.创建您自己的响应式设计
..自己创建样式..

//2.使用 Bootstrap是使用现成的 CSS 框架。
//Bootstrap 是最流行的开发响应式 web 的 HTML, CSS, 和 JS 框架。
Bootstrap 帮助您开发在任何尺寸都外观出众的站点：显示器、笔记本电脑、平板电脑或手机

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" 
  href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
</head>

<body>

<div class="container">
<div class="jumbotron">
  <h1>W3School Demo</h1> 
  <p>Resize this responsive page!</p> 
</div>
</div>

<div class="container">
<div class="row">
  <div class="col-md-4">
    <h2>London</h2>
    <p>London is the capital city of England.</p>
    <p>It is the most populous city in the United Kingdom,
    with a metropolitan area of over 13 million inhabitants.</p>
  </div>
  <div class="col-md-4">
    <h2>Paris</h2>
    <p>Paris is the capital and most populous city of France.</p>
  </div>
  <div class="col-md-4">
    <h2>Tokyo</h2>
    <p>Tokyo is the capital of Japan, the center of the Greater Tokyo Area,
    and the most populous metropolitan area in the world.</p>
  </div>
</div>
</div>

</body>
</html>


```

#### 16.HTML框架
```html
//通过使用框架，你可以在同一个浏览器窗口中显示不止一个页面。
//垂直框架
<html>
<frameset cols="25%,50%,25%">
  <frame src="/example/html/frame_a.html">
  <frame src="/example/html/frame_b.html">
  <frame src="/example/html/frame_c.html">
</frameset>
</html>

//水平框架
<html>
<frameset rows="25%,50%,25%">
  <frame src="/example/html/frame_a.html">
  <frame src="/example/html/frame_b.html">
  <frame src="/example/html/frame_c.html">
</frameset>
</html>


//假如一个框架有可见边框，用户可以拖动边框来改变它的大小。为了避免这种情况发生，可以在 <frame> 标签中加入：noresize="noresize"。
//重要提示：不能将 <body></body> 标签与 <frameset></frameset> 标签同时使用！不过，假如你添加包含一段文本的 <noframes> 标
签，就必须将这段文字嵌套于 <body></body> 标签内。（在下面的第一个实例中，可以查看它是如何实现的。）
<html>
<frameset cols="25%,50%,25%">
  <frame src="/example/html/frame_a.html">
  <frame src="/example/html/frame_b.html">
  <frame src="/example/html/frame_c.html">
<noframes>
<body>您的浏览器无法处理框架！</body>
</noframes>
</frameset>
</html>



//本例演示如何制作导航框架。导航框架包含一个将第二个框架作为目标的链接列表。名为 "contents.htm" 的文件包含三个链接。
<html>
<frameset cols="600,*">
  <frame src="/example/html/html_contents.html">
  <frame src="/example/html/frame_a.html" name="showframe">
</frameset>
</html>

//本例演示如何创建内联框架（HTML 页中的框架）。
<html>
<body>
<iframe src="/i/eg_landscape.jpg"></iframe>
<p>一些老的浏览器不支持 iframe。</p>
<p>如果得不到支持，iframe 是不可见的。</p>
</body>
</html>

<html>


//本例演示两个框架。其中的一个框架设置了指向另一个文件内指定的节的链接。这个"link.htm"文件内指定的节使用 <a name="C10"> 进行标识。
<frameset cols="20%,80%">
 <frame src="/example/html/frame_a.html">
 <frame src="/example/html/link.html#C10">
</frameset>
</html>

//本例演示两个框架。左侧的导航框架包含了一个链接列表，这些链接将第二个框架作为目标。第二个框架显示被链接的文档。导航框架其中的链接指向目标文件中指定的节
<html>
<frameset cols="180,*">
<frame src="/example/html/content.html">
//<a href ="/example/html/link.html" target ="showframe">没有锚的链接</a><br/>
<frame src="/example/html/link.html" name="showframe">
</frameset>
</html>
```
#### 17.iframe 用于在网页内显示网页。
```html
//17.1.添加 iframe 的语法
<iframe src="URL"></iframe>URL 指向隔离页面的位置。
//17.2 iframe - 设置高度和宽度
<iframe src="demo_iframe.htm" width="200" height="200"></iframe>
//17.3 iframe - 删除边框
frameborder 属性规定是否显示 iframe 周围的边框。设置属性值为 "0" 就可以移除边框：
<iframe src="demo_iframe.htm" frameborder="0"></iframe>
//17.4 iframe 可用作链接的目标（target）。链接的 target 属性必须引用 iframe 的 name 属性：
<iframe src="demo_iframe.htm" name="iframe_a"></iframe>
<p><a href="http://www.w3school.com.cn" target="iframe_a">W3School.com.cn</a></p>

```

#### 18.HTML Script
```html
<script type="text/javascript">
document.write("Hello World!")
</script>

<noscript> 标签
<!DOCTYPE html>
<html>
<body>
<script type="text/javascript">
document.write("Hello World!")
</script>
<noscript>Sorry, your browser does not support JavaScript!</noscript>
<p>不支持 JavaScript 的浏览器将显示 noscript 元素中的文本。</p>
</body>
</html>
```

#### 19.HTML 头部元素
```html
以下标签都可以添加到 head 部分:
<title>、<base>、<link>、<meta>、<script> 以及 <style>。

//1.标题
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<meta http-equiv="Content-Language" content="zh-cn" />
<title>标题不会显示在文档区</title>
</head>
<body>
<p>这段文本会显示出来。</p>
</body>
</html>

//2.所有链接一个目标:如何使用 base 标签使页面中的所有标签在新窗口中打开。
//<base> 标签为页面上的所有链接规定默认地址或默认目标（target）：
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<meta http-equiv="Content-Language" content="zh-cn" />
<base target="_blank" />
</head>
<body>
<a href="http://www.w3school.com.cn" target="_blank">这个连接</a> 将在新窗口中加载，因为 target 属性被设置为 "_blank"。
</body>

//3.文档描述:使用 <meta> 元素来描述文档。
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<meta name="author" content="w3school.com.cn">
<meta name="revised" content="David Yang,8/1/07">
<meta name="generator" content="Dreamweaver 8.0en">
</head>

//4.关键词
<meta name="description" content="HTML examples">
<meta name="keywords" content="HTML, DHTML, CSS, XML, XHTML, JavaScript, VBScript">

//5.重定向
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<meta http-equiv="Refresh" content="5;url=http://www.w3school.com.cn" />
```

#### 20.HTML实体元素
```html
HTML 中的预留字符必须被替换为字符实体。
在 HTML 中，某些字符是预留的。
在 HTML 中不能使用小于号（<）和大于号（>），这是因为浏览器会误认为它们是标签。
如果希望正确地显示预留字符，我们必须在 HTML 源代码中使用字符实体（character entities）。
&entity_name;
或者
&#entity_number;

	空格	&nbsp;	&#160;
<	小于号	&lt;	&#60;
>	大于号	&gt;	&#62;
&	和号	&amp;	&#38;
"	引号	&quot;	&#34;
'	撇号 	&apos; (IE不支持)	&#39;
￠	分（cent）	&cent;	&#162;
£	镑（pound）	&pound;	&#163;
¥	元（yen）	&yen;	&#165;
€	欧元（euro）	&euro;	&#8364;
§	小节	&sect;	&#167;
©	版权（copyright）	&copy;	&#169;
®	注册商标	&reg;	&#174;
™	商标	&trade;	&#8482;
×	乘号	&times;	&#215;
÷	除号	&divide;	&#247;
```

#### 21.URL 也被称为网址。

```html
scheme://host.domain:port/path/filename

URL 编码
URL 只能使用 ASCII 字符集来通过因特网进行发送。
由于 URL 常常会包含 ASCII 集合之外的字符，URL 必须转换为有效的 ASCII 格式。
URL 编码使用 "%" 其后跟随两位的十六进制数来替换非 ASCII 字符。
URL 不能包含空格。URL 编码通常使用 + 来替换空格。
```

#### 22.颜色

```html
//html4.0
aqua, black, blue, fuchsia, gray, green, lime, maroon, navy, olive, purple, red, silver, teal, white, yellow
```
跨平台色
![SamuelChan/20180828111056.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180828111056.png)


#### 23.HTML <!DOCTYPE>

```html
HTML5 : <!DOCTYPE html>

HTML 4.01 : <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

XHTML 1.0 : <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

```

#### 24.XHTML

```html
什么是 XHTML？
XHTML 指的是可扩展超文本标记语言
XHTML 与 HTML 4.01 几乎是相同的
XHTML 是更严格更纯净的 HTML 版本
XHTML 是以 XML 应用的方式定义的 HTML
XHTML 是 2001 年 1 月发布的 W3C 推荐标准
XHTML 得到所有主流浏览器的支持

//文档结构
XHTML DOCTYPE 是强制性的
<html> 中的 XML namespace 属性是强制性的
<html>、<head>、<title> 以及 <body> 也是强制性的
//元素语法
XHTML 元素必须正确嵌套
XHTML 元素必须始终关闭
XHTML 元素必须小写
XHTML 文档必须有一个根元素
//属性语法
XHTML 属性必须使用小写
XHTML 属性值必须用引号包围
XHTML 属性最小化也是禁止的
```

#### 25.表单
```html
HTML 表单用于搜集不同类型的用户输入。

form元素是一个块元素,前后会产生换行

<form> 元素定义 HTML 表单：
<form>
 .
form elements
 .
</form>

表单元素指的是不同类型的 input 元素、复选框、单选按钮、提交按钮等等。

1.<input> 元素
<input> 元素是最重要的表单元素。
<input> 元素有很多形态，根据不同的 type 属性。
类型	描述
text	定义常规文本输入。
radio	定义单选按钮输入（选择多个选择之一）
submit	定义提交按钮（提交表单）

<form>
 First name:<br>
<input type="text" name="firstname">
<br>
 Last name:<br>
<input type="text" name="lastname">
</form> 

2.<input type="radio"> 定义单选按钮。
单选按钮允许用户在有限数量的选项中选择其中之一：
<form>
<input type="radio" name="sex" value="male" checked>Male
<br>
<input type="radio" name="sex" value="female">Female
</form> 


3.提交按钮
//action 属性定义在提交表单时执行的动作。
//如果要正确地被提交，每个输入字段必须设置一个 name 属性。
<form action="action_page.php">
First name:<br>
<input type="text" name="firstname" value="Mickey">
<br>
Last name:<br>
<input type="text" name="lastname" value="Mouse">
<br><br>
<input type="submit" value="Submit">
</form> 

//<form action="action_page.php" method="GET"> 或 <form action="action_page.php" method="POST">

//用 <fieldset> 组合表单数据 <fieldset> 元素组合表单中的相关数据 <legend> 元素为 <fieldset> 元素定义标题。
<form action="action_page.php">
<fieldset>
<legend>Personal information:</legend>
First name:<br>
<input type="text" name="firstname" value="Mickey">
<br>
Last name:<br>
<input type="text" name="lastname" value="Mouse">
<br><br>
<input type="submit" value="Submit"></fieldset>
</form> 


//HTML <form> 元素，已设置所有可能的属性，是这样的：
<form action="action_page.php" method="GET" target="_blank" accept-charset="UTF-8"
ectype="application/x-www-form-urlencoded" autocomplete="off" novalidate>
下面是 <form> 属性的列表：
accept-charset	规定在被提交表单中使用的字符集（默认：页面字符集）。
action	规定向何处提交表单的地址（URL）（提交页面）。
autocomplete	规定浏览器应该自动完成表单（默认：开启）。
enctype	规定被提交数据的编码（默认：url-encoded）。
method	规定在提交表单时所用的 HTTP 方法（默认：GET）。
name	规定识别表单的名称（对于 DOM 使用：document.forms.name）。
novalidate	规定浏览器不验证表单。
target	规定 action 属性中地址的目标（默认：_self）。

如果您省略了提交按钮的 value 属性，那么该按钮将获得默认文本
//Input Type: password
<input type="password" name="psw">

//Input Type: checkbox
<input type="checkbox" name="vehicle" value="Bike">I have a bike
<input type="checkbox" name="vehicle" value="Car">I have a car 

//Input Type: button
<input type="button" onclick="alert('Hello World!')" value="Click Me!">

//Input Type: image
<input type="image" src="/i/eg_submit.jpg" alt="Submit" width="128" height="128"/>


//HTML5 增加了多个新的输入类型：
color
date
datetime
datetime-local
email
month
number
range
search
tel
time
url
week

//输入限制
属性	描述
disabled	规定输入字段应该被禁用。
max	规定输入字段的最大值。
maxlength	规定输入字段的最大字符数。
min	规定输入字段的最小值。
pattern	规定通过其检查输入值的正则表达式。
readonly	规定输入字段为只读（无法修改）。
required	规定输入字段是必需的（必需填写）。
size	规定输入字段的宽度（以字符计）。
step	规定输入字段的合法数字间隔。
value	规定输入字段的默认值。


//input type="number"
<input type="number" name="quantity" min="1" max="5">
```
![SamuelChan/20180828135152.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180828135152.png)

```html
HTML5 为 <input> 增加了如下属性：
autocomplete:双击input,可以选择
autofocus:页面加载完毕,自动聚焦到第一个输入框
form
formaction
formenctype
formmethod
formnovalidate
formtarget
height 和 width
list
min 和 max
multiple
pattern (regexp)
placeholder:
required
step
```




