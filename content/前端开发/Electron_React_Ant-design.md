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

```shell
# 使用HomeBrew升级macnode
brew update && brew upgrade node && npm update -g npm
```

而 `npm` 则是 `Node.js` 的一个包管理工具，你可以使用 `npm` 安装这样那样的 `JavaScript` 包，就像python的pip那样简单。

``` shell
# npm全局安装包在MacOS: /usr/local/lib/node_modules/
> npm install -g xx
> -S, --save: Package will appear in your dependencies.
> -D, --save-dev: Package will appear in your devDependencies.
> -O, --save-optional: Package will appear in your optionalDependencies.

# npm仓库在国外，在国内访问很慢，有时还会出现请求超时修改仓库镜像地址
> npm config set registry http://registry.npm.taobao.org/
# 可以查看是否更换成功
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

## 三. 动手

### 1. 创建一个React app

```sh

# 安装 create-react-app 命令,如果已将安装请忽略
npm install -g create-react-app
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

![SamuelChan/20181021123255.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181021123255.png)

![SamuelChan/20181021214054.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181021214054.png)

## electron安装,配置运行

### electron安装

```
> npm install -save electron
# npm WARN ajv-keywords@3.2.0 requires a peer of ajv@^6.0.0 but none was installed.
> npm install ajv@^6.0.0
```

![SamuelChan/20181021123123.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181021123123.png)
  
### 配置

在工程根目录下面新建 `main.js`,这个文件和 `electron-quick-start` 中的官方默认 `main.js` 几乎一模一样，只修改了加载应用这入口这一个地方：

```js
// 引入electron并创建一个Browserwindow
const {app, BrowserWindow} = require('electron')
const path = require('path')
const url = require('url')

// 保持window对象的全局引用,避免JavaScript对象被垃圾回收时,窗口被自动关闭.
let mainWindow

function createWindow () {
//创建浏览器窗口,宽高自定义具体大小你开心就好
mainWindow = new BrowserWindow({width: 800, height: 600})

  /* 
   * 加载应用-----  electron-quick-start中默认的加载入口
    mainWindow.loadURL(url.format({
      pathname: path.join(__dirname, 'index.html'),
      protocol: 'file:',
      slashes: true
    }))
  */
  // 加载应用----适用于 react 项目
  mainWindow.loadURL('http://localhost:3000/');
  
  // 打开开发者工具，默认不打开
  // mainWindow.webContents.openDevTools()

  // 关闭window时触发下列事件.
  mainWindow.on('closed', function () {
    mainWindow = null
  })
}

// 当 Electron 完成初始化并准备创建浏览器窗口时调用此方法
app.on('ready', createWindow)

// 所有窗口关闭时退出应用.
app.on('window-all-closed', function () {
  // macOS中除非用户按下 `Cmd + Q` 显式退出,否则应用与菜单栏始终处于活动状态.
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', function () {
   // macOS中点击Dock图标时没有已打开的其余应用窗口时,则通常在应用中重建一个窗口
  if (mainWindow === null) {
    createWindow()
  }
})

// 你可以在这个脚本中续写或者使用require引入独立的js文件.
```

配置 `package.json`

```json
{
  "name": "knownsec-fed",
  "version": "0.1.0",
  "private": true,
  "main": "main.js", // 配置启动文件
  "homepage":".", // 
  "dependencies": {
    "electron": "^1.7.10",
    "react": "^16.2.0",
    "react-dom": "^16.2.0",
    "react-scripts": "1.1.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test --env=jsdom",
    "eject": "react-scripts eject",
    "electron-start": "electron ." // 配置electron的start，区别于web端的start
  }
}
```

### 运行

```sh
# a. 启动 react 项目
npm start
# b. 启动 electron
npm run electron-start
```

## 四. 集成Ant-design前端UI库

```sh
npm install -g yarn

# (1)安装yarn之后
npm start =====> yarn start

# (2)引入 ant-design
yarn add antd

# (3)安装react-app-rewired，这是一个自定义配置react项目的工具：
yarn add react-app-rewired --dev

# (4)修改根目录下的package.json：
# /package.json
"scripts": {
-    "start": "react-scripts start",
-    "build": "react-scripts build",
-    "test": "react-scripts test --env=jsdom",
+    "start": "react-app-rewired start",
+    "build": "react-app-rewired build",
+    "test": "react-app-rewired test --env=jsdom",
}

# (5)在项目根目录下创建一个config-overrides.js，用于书写自定义配置：
# /config-overrides.js
module.exports = function override(config, env) {
  return config;
};

# (6)babel-plugin-import，这是一个按需加载代码、样式的babel插件:
yarn add babel-plugin-import --dev

# (7)修改config-overrides.js：
# /config-overrides.js
+ const { injectBabelPlugin } = require('react-app-rewired');
  module.exports = function override(config, env) {
+   config = injectBabelPlugin(['import', { libraryName: 'antd', libraryDirectory: 'es', style: 'css' }], config);
    return config;
  };

# (8)添加路由
# public下新建一个html文件,这个文件将来将会作为Electron的入口网页文件
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Electron Test</title>
</head>
<body>
    <div id="root"></div>
</body>
</html>

# 安装前端路由react-router-dom：
yarn install react-router-dom

# 安装完成之后，在src目录下新建一个入口js文件index.js、一个路由组件文件router.js，再创建一个文件夹叫page用于存储页面组件文件，里面再建立一个文件叫做index.js，用于存储首页组件，这时项目结构如下：
# 这时候我们先修改/src/page/index.js文件，在里面写一个首页的组件：
import React from 'react';
import { Button } from 'antd';

export class IndexPage extends React.Component {
    render() {
        return (
            <div>
                <Button>Click Me!</Button>
            </div>
        );
    }
}

# 然后打开路由文件/src/router.js，写路由组件：
import React from 'react';
import { HashRouter, Route, Switch } from 'react-router-dom';
import { IndexPage } from "./page";

export class MainRouter extends React.Component {
    render() {
        return (
            <HashRouter>
                <Switch>
                    <Route exact path={'/'} component={IndexPage}/>
                </Switch>
            </HashRouter>
        );
    }
}

# 以后添加新页面只需要在page中写一个新的页面组件文件，然后修改路由文件，在Switch中添加path与组件的对应关系即可。
# 接下来再在/src/index.js这一入口文件中渲染路由组件：
import React from 'react';
import ReactDom from 'react-dom';
import { MainRouter } from "./router";

ReactDom.render(
    <MainRouter/>,
    document.getElementById('root')
);






```




## 参考资料


[React + Electron 搭建一个桌面应用](http://www.kindemh.cn/post/51)

