# Apple Security Guide

> [iOS_Security_Guide iOS 12 更新2018.9,英文](https://www.apple.com/business/site/docs/iOS_Security_Guide.pdf)
>
> [iOS_Security_Guide iOS 11 更新2018.1,中文](https://www.apple.com/cn/business/site/docs/iOS_Security_Guide.pdf)
>
> 本文内容将会基于最新的iOS_Security_Guide_iOS12_2018.9

## 概述

- 系统安全性 : iPhone、 iPad 和 iPod touch 上安全的一体化软硬件平台。

- 加密和数据保护 : 一种对用户数据进行保护的架构和设计。 在设备丢失或被盗， 或有未 授权人员尝试使用或修改设备时， 能够保护设备上的用户数据。

- 应用安全性:确保应用安全运行，同时又不破坏平台完整性的系统。

- 网络安全性:针对传输中的数据提供安全认证和加密的行业标准联网协议。

- Apple Pay : Apple 推行的安全支付方式。

- 互联网服务 : Apple 用来提供信息通信、 同步和备份服务的网络基础架构。

- 用户密码管理 : 密码限制和其他授权源访问密码

- 设备控制 : 允许对 iOS 设备进行管理、 防止未经授权的使用以及在设备丢失或被盗时 启用远程擦除的方法。

- 隐私控制 : iOS 中可用于控制 “定位服务” 和用户数据访问权限的功能。

- 安全证书和计划 : Information on ISO certifications, Cryptographic validation, Common Criteria Certification, and commercial solutions for classified (CSfC).

![SamuelChan/20181011144325.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181011144325.png)

## 一.系统安全性

## 二.加密和数据保护

> “设置” 中的 “抹掉所有内容和设置” 选项会清除可擦除储存空间上的所有密钥， 备份可以备份储存空间上的所有密钥吗?



1.数据储存加密

passCode用来干嘛? 加密"密钥包”是怎么做的
touchId,faceId: 储存的是固定数据还是模式匹配? 如果是模式匹配就不能用来加密
iCloud机制(Guide比较浅显,找资料): masterKey漏洞 → 木马机,主要是由iCloud同步造成的;本地储存还是安全的
fileSystem Key : 数据加密/验证
perFile Key: 数据加密/验证
关注廉价机型安全: 5c(32位系统),缺v乏硬件层面上,防止暴力破解的芯片
2.数据传输加密

3.结合API文档看，考虑怎样通过api给app提供尽可能安全的存储。

## iPhone XS Max 特殊安全方式

A12硬件和arm64e(arm8.3)保护的iOS 12,苹果iPhone XS等机型中,采用Pointer Authentication Codes(PAC)等多种高级防御机制

> 2018.9.27被盘古团队破解

## iOS越狱各个概况


内核与CPU的关系
内核是CPU的核心，一个CPU可以有多个内核（也就是多核处理器），而一个内核只能属于一个CPU。


芯片 | 机型 | 描述
---------|----------|---------
 [A4](https://zh.wikipedia.org/wiki/Apple_A4) | iPhone 4 | 
 [A5](https://zh.wikipedia.org/wiki/Apple_A5) | iPhone 4S | CPU提升两倍,GPU性能较前一代A4提升7倍之多
 [A6](https://zh.wikipedia.org/wiki/Apple_A6) | iPhone 5和iPhone 5c | CPU和GPU的能力比较Apple A5强劲两倍。
 [A7](https://zh.wikipedia.org/wiki/Apple_A7) | iPhone 5S、iPad Air和iPad mini2 | CPU与GPU效能都是Apple A6的两倍; iPhone成为全球首款采用64位元处理器的智能手机
 [A8](https://zh.wikipedia.org/wiki/Apple_A8) | iPhone 6、iPhone 6 Plus、iPad mini 4、iPod touch 6、Apple TV和HomePod | CPU性能高25%，GPU性能高50%，能源效益高50%
 [A9](https://zh.wikipedia.org/wiki/Apple_A9) | iPhone 6S和iPhone 6S Plus | CPU性能提高了70%，而GPU性能提高了90%
 [A10](https://zh.wikipedia.org/wiki/Apple_A10_Fusion) | iPhone 7和iPhone 7 Plus | CPU性能提升了40%，在图形运算提升了50%
 [A11](https://zh.wikipedia.org/wiki/Apple_A11_Bionic) | iPhone 8、iPhone 8 Plus及iPhone X |  “仿生”（Bionic）;CPU部分高性能核心和节电核心的性能分别提升25%及70%，GPU性能较前代提升30%
 [A12](https://zh.wikipedia.org/wiki/Apple_A12_Bionic) | iPhone XS、iPhone XS Max和iPhone XR | CPU处理性能较上一代A11 Bionic提升最高约15%，节能最高达50%。
