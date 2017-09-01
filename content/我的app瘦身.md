<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [1.资源清理](#1%E8%B5%84%E6%BA%90%E6%B8%85%E7%90%86)
- [2.编译选项](#2%E7%BC%96%E8%AF%91%E9%80%89%E9%A1%B9)
- [3.可执行文件瘦身](#3%E5%8F%AF%E6%89%A7%E8%A1%8C%E6%96%87%E4%BB%B6%E7%98%A6%E8%BA%AB)
- [3.1 (失败)](#31-%E5%A4%B1%E8%B4%A5)
- [3.2.还剩下的方法---能搜到的好文章 :(都试了一下,感觉暂时项目还不需要做那么深的优化,delay)](#32%E8%BF%98%E5%89%A9%E4%B8%8B%E7%9A%84%E6%96%B9%E6%B3%95---%E8%83%BD%E6%90%9C%E5%88%B0%E7%9A%84%E5%A5%BD%E6%96%87%E7%AB%A0-%E9%83%BD%E8%AF%95%E4%BA%86%E4%B8%80%E4%B8%8B%E6%84%9F%E8%A7%89%E6%9A%82%E6%97%B6%E9%A1%B9%E7%9B%AE%E8%BF%98%E4%B8%8D%E9%9C%80%E8%A6%81%E5%81%9A%E9%82%A3%E4%B9%88%E6%B7%B1%E7%9A%84%E4%BC%98%E5%8C%96delay)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### 1.资源清理
- 使用LSUnusedResources  
 ![](http://wx3.sinaimg.cn/mw1024/6a0be6b3gy1fd8ow5jqm1j2082099di4.jpg)
- 使用ImageOptim进行图片优化

### 2.编译选项 

1. BitCode开启:[看这里](http://www.cocoachina.com/ios/20150818/13078.html)
> 当我们提交程序到App store上时，Xcode会将程序编译为一个中间表现形式(bitcode)。然后App store会再将这个botcode编译为可执行的64位或32位程序。

2. BuildSettings->Optimization Level，Xcode默认设置为“Fastest ,Smallest”，保持默认即可。  
3. Build Settings-> Linking->Dead Code Stripping 设置成 YES  
4. Deployment Postprocessing 设置成YES  
5. Strip Linked Product 设置成YES  
6. 工程的Enable C++ Exceptions和Enable Objective-C Exceptions选项都设置为NO。手动管理异常。  
7. symbols hidden by default选项设置为YES。  
8. 所有没有使用C++动态特性的lib库（搜索工程没有使用dynamic_cast关键字） Enable C++ Runtime Types 选项设置为NO。  
9. Strip Debug Symbols During Copy 和 Symbols Hidden by Default 在release版本应该设为yes，可以去除不必要的调试符号。Symbols Hidden by Default会把所有符号都定义成”private extern”，具体意思和作用我还不清楚，有待研究，但设了后会减小体积。这些选项目前都是XCode默认选项，但旧版XCode生成的项目可能不是，可以检查一下。  
10. 常见的指令集体系有: armv7 armv7s arm64(真机)  i386 x86_64(模拟器),, 高版本的指令集体系向下兼容低版本,但是为了让各种指令集机器运行在最佳的状态,在release时需要生成各种指令集  
   指令集是有下面几个参数确定的: Architecture, Valid architectures, Build Active Architecture Only来确定的, 前两个参数的合集是计划生成的指令集, 而最后一个参数是确定是否在编译时从这个合集的配置中选取最合适机子的指令集(分debug和release),  
> <https://www.innerfence.com/howto/apple-ios-devices-dates-versions-instruction-sets> Apple设备指令集合
  <http://www.cocoachina.com/ios/20140915/9620.html> Apple移动设备处理器指令集 armv6、armv7、armv7s及arm64

### 3.可执行文件瘦身

### 3.1 (失败)

LinkMap文件是Xcode产生可执行文件的同时生成的链接信息，用来描述可执行文件的构造成分，包括代码段（TEXT）和数据段（DATA）的分布情况。只要设置Project->Build Settings->Write Link Map File为YES，build完后就可以在设置的路径看到LinkMap文件了。

我们可以用脚本从linkmap中统计出每个.o目标文件占用的体积和每个.a静态库占用的体积 【[脚本链接](https://gist.github.com/bang590/8f3e9704f1c2661836cd)】
LinkMap:从统计结果来看，静态库文件和文件占大头
命令:   

1. 将linkMap.txt中的信息列出: node lineMap.js /Users/samuelchan/Desktop/linkMap.txt -hl 
2. 拆分静态库和合并静态库: **然而并没有用,SDK的静态库文件的确是减小了,但是打包出来体积完全不变,猜测打包的时候应该第三方SDK应该是会根据Valid architectures来进行选择性打包**
```objecitve-c
lipo -info libWeChatSDK.a
Architectures in the fat file: libWeChatSDK.a are: armv7 armv7s i386 x86_64 arm64 
i386,x86_64,这不是模拟器的指令集么？去掉看能不能减少体积？armv7可以兼容armv7s，armv7s也可以删了，只保留armv7和arm64
lipo libWeChatSDK.a -thin armv7 -output libWeChatSDK-armv7.a
lipo libWeChatSDK.a -thin arm64 -output libWeChatSDK-arm64.a
lipo create libWeChatSDK-armv7.a libWeChatSDK-arm64.a -output libWeChatSDK-device.a
```

### 3.2.还剩下的方法---能搜到的好文章 :(都试了一下,感觉暂时项目还不需要做那么深的优化,delay)

[微信安装包瘦身](http://mp.weixin.qq.com/s?__biz=MzA3ODg4MDk0Ng==&mid=2651112856&idx=1&sn=b2c74c62a10b4c9a4e7538d1ad7eb739)  
[滴滴-基于clang插件的一种iOS包大小瘦身方案](http://www.infoq.com/cn/articles/clang-plugin-ios-app-size-reducing?utm_source=articles_about_iOS&utm_medium=link&utm_campaign=iOS)  
[阿里-iOS瘦身之删除无用的mach-O文件](http://mp.weixin.qq.com/s?__biz=MzA3ODg4MDk0Ng==&mid=2651112096&idx=1&sn=ce8fccce7d5f70e30c078e63e8ea0d15&scene=21#wechat_redirect)  
[Tencent-手机APP安装包缩减方案](http://tmq.qq.com/2016/11/mobileapp_reduceprogram-2/)  
[Unknown](http://ivanyuan.farbox.com/post/liao-liao-an-zhuang-bao-shou-shen-na-xie-shi)