# Electron + React + Ant-design

> React作为**前端界面框架**
>
> Ant-Design作为**UI库**
>
>Electron作为**Native支持的项目搭建**

## 一. Electron

> 是在本地应用上跑一个抽出来的浏览器，浏览器上放你写的页面。

**Chromium** is a Webkit based web browser with the V8 javascript engine. It supports all the usual browser and DOM APIs and thus is good for making web pages and not good at interacting with the underlying system.

**Node.js** was built by striping out the V8 engine, making a headless command line application, and adding extensive APIs to access the file system, require() other files, run other shell programs, etc. (things you'd expect of a true scripting language.

**Electron** in a simplified way is an attempt to replace the V8 engine used in Chromium with the new more general purpose oriented one of Node.js. It exposes a few extra APIs to node.js to allow for opening chromium windows, but also every chromium window using a \<script\> tag will interpret it with the node.js engine.

**Why Electron?** The reason that Chromium can't do this by itself is because it was originally designed to be a web browser and in web browsers file system APIs would be unheard of as typically files are hosted on a remote server and accessing files on a user's computer would be a security risk (because why should any single webpage have access to all your files?).

- 在 Electron 中, 把 package.json 中设定的 main 脚本的所在进程称为 **主进程**

- 因为 Electron 是通过 Chromium 来显示页面,所以 Chromium 自带的多进程架构也一同被利用。这样每个页面都运行着一个独立的进程,它们被统称为 **渲染进程**

- 通常来说,浏览器中的网页会被限制在沙盒环境中运行并且不允许访问系统原生资源。但是由于 Eelectron 用户可在页面中调用 Node.js API，所以可以和底层操作系统直接交互。

### 1. Node.js

```json
Node.js 是一个基于 Chrome V8 引擎的 JavaScript 运行
环境。Node.js 使用了一个事件驱动、非阻塞式 I/O 的模型，
使其轻量又高效。 Node.js 的包管理器 npm是全球最大的开源库生态系统。
```

传统的 `JavaScript` 只能依赖浏览器而运行，而 `Node.js` 则将`Chrome` 的浏览器引擎抽了出来并加以改进，使得 `JavaScript` 可以脱离浏览器而运行。

而 `npm` 则是 `Node.js` 的一个包管理工具，你可以使用 `npm` 安装这样那样的 `JavaScript` 包，就像python的pip那样简单。

``` sh
> npm install -g xx : /usr/local/lib/node_modules/
> -S, --save: Package will appear in your dependencies.
> -D, --save-dev: Package will appear in your devDependencies.
> -O, --save-optional: Package will appear in your optionalDependencies.

> npm仓库在国外，在国内访问很慢，有时还会出现请求超时修改仓库镜像地址
> npm config set registry http://registry.npm.taobao.org/
> 可以查看是否更换成功
>npm get registry


```

`Node.js` 的出现，使得这样那样的前端开发工具、框架如春笋般涌现，如Grunt、Webpack、React、Vue等等。而且**JavaScript能够脱离浏览器而运行，也从某种意义上使JavaScript变成了一个跨平台Native语言。可以说，Node.js**，就是如今前端的核心。

### 2. 构建工具

- 将每一个JavaScript文件压缩，删去所有无效字符，输出为中间件

- 判断各个中间件之间的依赖关系

- 根据依赖关系将所有中间件打包成一个输出文件，这个输出文件中具有原来各个JavaScript中的所有功能，但是体积更小，而且依赖关系被严格限制并且无误

现在常见的构建工具有`Grunt`、`Webpack`等。

### 3.前端路由

前端路由的存在意义就在于将路径逻辑交由前端来处理，而不是后端，这样能让后端专注与真正需要后端资源的请求的处理。

**前端路由** 往往与 **构建工具** 、**前端界面框架**相互配合，

- 构建工具负责将所有文件打包，
- 而前端界面框架往往自己带有自己的前端路由框架，最后打包出来的输出文件，一般只有一个 inedx.html、一个 bunble.js和其他的资源文件。
- 一个 index.html，配合 bunble.js，就能展现所有页面的内容。

这样既能减少请求量，又符合人们的正常思想，一个网站就是一个应用，像Native那样，应用内部的逻辑由应用自己处理，真正需要后端支援的时候才发送请求到服务器，让服务器处理



## 二. 前端开发框架

> 以上3大框架均不支持`IE8`以下；
IE9以下解决方法:Bootstrap (在IE8也会不支持一些样式和属性)+jQuery；
其他框架稳定性欠缺

### 1. Angular，React,Vue.js，Angular2

> 虽然Vue.js被定义为MVC framework，但其实Vue本身还是一个library，加了一些其他的工具，可以被当成一个framework。ReactJS也是library，同样道理，配合工具也可以成为一个framework

![SamuelChan/20181020191152.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181020191152.png)

### 2. 数据流

Vue.js,Angular 都是双向数据流

MVVM流的Angular和Vue，都是通过类似模板的语法，描述界面状态与数据的绑定关系，然后通过内部转换，把这个结构建立起来，当界面发生变化的时候，按照配置规则去更新相应的数据，然后，再根据配置好的规则去，从数据更新界面状态。
React推崇的是函数式编程和单向数据流： **给定原始界面（或数据），施加一个变化，就能推导出另外一个状态（界面或者数据的更新）。**
React和Vue都可以配合Redux来管理状态数据。

### 3. 渲染

React 的渲染建立在 Virtual DOM 上——一种在内存中描述 DOM 树状态的数据结构。当状态发生变化时，React 重新渲染 Virtual DOM，比较计算之后给真实 DOM 打补丁。
Virtual DOM 提供了函数式的方法描述视图，它不使用数据观察机制，每次更新都会重新渲染整个应用，因此从定义上保证了视图与数据的同步。它也开辟了 JavaScript 同构应用的可能性。

### 4. 模块化与组件化组件化

React
一个 React 应用就是构建在 React 组件之上的。 组件有两个核心概念：props,state。 一个组件就是通过这两个属性的值在 render 方法里面生成这个组件对应的 HTML 结构。

**React 认为组件才是王道，而组件是和模板紧密关联的，组件模板和组件逻辑分离让问题复杂化了**。所以就有了 `JSX` 这种语法，就是为了把 HTML 模板直接嵌入到 JS 代码里面，这样就做到了模板和组件关联，但是 JS 不支持这种包含 HTML 的语法，所以需要通过工具将 `JSX` 编译输出成 JS 代码才能使用（可以进行跨平台开发的依据，通过不同的解释器解释成不同平台上运行的代码，由此可以有RN和React开发桌面客户端）。

### 5. 语法

React,Vue,Angular2都支持ES6

React 以 JavaScript 为中心, React 将 “HTML” 嵌入 JS。

Angular 2 依然保留以 HTML 为中心。Angular 2 将 “JS” 嵌入 HTML。

React 推荐的做法是 JSX + inline style，也就是把 HTML 和 CSS 全都整进 JavaScript 了。

Vue 的默认 API 是以简单易上手为目标，但是进阶之后推荐的是使用 webpack + vue-loader 的单文件组件格式（template,script,style写在一个vue文件里作为一个组件）


## 三. 前端UI库


## 四. 动手

### 1. 创建一个React app

```sh

# 安装 create-react-app 命令,如果已将安装请忽略
npm install -g first-react
# 创建 first-react 项目
create-react-app first-react
# 启动项目
cd first-react && npm start

=============================================
Inside that directory, you can run several commands:

>  npm start
Starts the development server.
>  npm run build
Bundles the app into static files for production.
>  npm test
Starts the test runner.
>  npm run eject
Removes this tool and copies build dependencies, 
configuration files and scripts into the app 
directory. If you do this, you can’t go back!

We suggest that you begin by typing:
> cd first-react
> npm start
Happy hacking!
```

## 安装electron

```sh

> npm install -save electron

```