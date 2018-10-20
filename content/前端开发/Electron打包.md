# Electron打包

## 打包 react 项目

首先修改 main.js, 因为现在你要将 react 项目打包在 build 文件夹下面，所以加载应用处改成如下！当然也可在某个配置文件里面配置是否属于开发，此处用if判断一下从未进行选择执行哪段加载应用代码。但是这里为了简便，暂且使用直接修改的方式：

```js
// 加载应用----react 打包
mainWindow.loadURL(url.format({
  pathname: path.join(__dirname, './build/index.html'),
  protocol: 'file:',
  slashes: true
}))
// 加载应用----适用于 react 开发时项目
// mainWindow.loadURL('http://localhost:3000/');
```

默认情况下，homepage 是 http://localhost:3000，build 后，所有资源文件路径都是 /static，而 Electron 调用的入口是 file :协议，/static 就会定位到根目录去，所以找不到静态文件。在 package.json 文件中添加 homepage 字段并设置为"."后，静态文件的路径就变成了相对路径，就能正确地找到了添加如下配置：

```js
"homepage":"."
```

然后就开始打包 react：

```sh
npm run-script build
```

此时，根目录下面将多出一个build文件夹。

### 打包 electron

常用打包插件
electron-builder
electron-packager

安装electron-packager
# knownsec-fed目录下安装electron-packager包
npm install electron-packager --save-dev
# 安装electron-packager命令
npm install electron-packager -g
复制代码electron-packager命令介绍
  electron-packager <location of project> <name of project> <platform> <architecture> <electron version> <optional options>
复制代码
location of project: 项目的本地地址，此处我这边是 ~/knownsec-fed
location of project: 项目名称，此处是 knownsec-fed
platform: 打包成的平台
architecture: 使用 x86 还是 x64 还是两个架构都用
electron version: electron 的版本

于是，根据我这边的情况在 package.json 文件的在 scripts 中加上如下代码：
"package": "electron-packager ~/knownsec-fed/build knownsec-fed --all --out ~/ --version 1.7.10   
复制代码开始打包
npm run-script package
复制代码提醒
由于打包的时候会把浏览器内核完整打包进去，所以就算你的项目开发就几百k的资源，但最终的打包文件估计也会比较大。


作者：创宇前端
链接：https://juejin.im/post/5a6a91276fb9a01cbd58ce32
来源：掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。