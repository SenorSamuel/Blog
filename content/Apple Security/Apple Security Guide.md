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

## 二.加密和数据保护（Encryption and Data Protection）

> “设置” 中的 “抹掉所有内容和设置” 选项会清除可擦除储存空间上的所有密钥， 备份可以备份储存空间上的所有密钥吗?

`Secure Boot Chain`, `CodeSigning`, and `Runtime Process Security`能保证只有被信任的code和appps才能运行在设备上面.

而在设备丢失/非法尝试修改设备,`加密和数据保护`能保证用户数据

苹果用户可以[远程擦除设备](https://support.apple.com/zh-cn/HT201472):擦除储存空间上的**所有**密钥，从而使设备上的所有用户数据因为处于加密状态而不可访问

### #0x00 硬件安全功能

> iPhone闪存使用[NAND](https://www.theiphonewiki.com/wiki/NAND)

加密方案需要考虑手机`速度`和`电量`

iOS设备在`闪存`和`主系统内存`都有DMA通道,DMA通道内置专用的AES加密引擎,实现文件高效加密.在A9之后的的A系列处理器,闪存位于独立的总线,只有通过它(当然也是DMA通道)才能访问到用户数据

设备的唯一ID **UID** 和设备组ID **GID** 是 AES 256 位密钥， 密钥已在制造过程中被固化(**UID**)或编译(**GID**)在`应用程序处理器`和`安全隔区`中。

- 任何软件和固件都办法读取到UID/GID。
- 软件和固件只能获取专用AES通道使用UID/GID作为密钥来加密/解密之后的结果。
- JTAG 或其他调试接口也读取不到UID/GID。

#### UID (Unique ID)

在A9及以更新的处理器中,生产过程中每个安全隔区会生成自己的 UID(唯一ID)。 因为每台设备的 UID 都是唯一的，且完全是在安全隔区内生成， 而不是在设备外的制造系统中生成，因此 **Apple 或其任何供应商都无法访问或存储UID**。

在安全隔区中运行的软件利用**UID**来保护设备特定的密钥。**UID**可以将数据绑定到对应的设备中，例如：

> 用于保护文件系统的密钥层次结构（key hierarchy）就包括 UID， 因此如果将存储芯片从一台设备整个移至另一台设备， 文件将不可访问。 UID 与设备上的任何其他标识符都无关。

#### GID (Group ID)

**GID**对于同一系列的处理器是一样的

#### 其他

- 所由其他的加密密钥由系统的`random number generator (RNG)`使用基于CTR_DRBG的算法生成，系统熵是由`启动期间从时间变化`以及`设备启动后从中断计时中生成的`。

- 而对于安全隔区，生成的密钥使用的是其`真正的硬件随机数生成器`， 它基于多个环形振荡器并经过 CTR_DRBG 后处理。

- `安全抹掉`存储的密钥与生成它们一样重要。在闪存上执行这项操作尤其具有挑战性，例如，在`闪存上损耗均衡 (wear-leveling)` 可能意味着需要抹掉多份数据副本。为了解决该问题，iOS 设备加入了一种专用于安全擦除数据的功能，称为`可擦除存储器`。此功能通过 访问基础存储技术(例如 NAND)直接进行非常低级别的寻址并抹掉少量数据块。

### 0x01 文件数据保护（File Data Protection）

`Data Protection`通过以下两点实现：

- 建立在每台 iOS 设备的硬件加密技术基础上
- 构造和管理密钥的多层次结构

 Data Protection is controlled on a per-file basis by assigning each file to a class; accessibility is determined by whether the class keys have been unlocked. With the advent of the Apple File System (APFS), the file system is now able to further sub-divide the keys into a per-extent basis (portions of a file can have different keys).

#### 整体架构

![SamuelChan/20181015140630.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181015140630.png)

> All wrapped file key handling occurs in the Secure Enclave; the file key is never directly exposed to the application processor. At boot time, the Secure Enclave negotiates an ephemeral key with the AES engine. When the Secure Enclave unwraps a file’s keys, they are rewrapped with the ephemeral key(an ephemeral, per-boot key) and sent back to the application processor.

所有的file key 封装 / 解封装 handling都发生在安全隔区内

安全隔区会使用与AES hardware engine协商生成的**ephemeral key**来封装目标key,保证应用处理器(application processor)读取不到

文件创建 → Data Protection新建一个256位的key(**PerFile Key**)给硬件AES引擎 → 硬件AES引擎使用这个key来加密将会被写入flash memory的文件; A7之前:AES-CBC;A7之后:AES-XTS; 加密用的vector:用 **PerFile Key** 的SHA-1来加密文件的块偏移

**PerFile Key**被 **Class Key** 封装([NIST AES](https://tools.ietf.org/html/rfc3394)), 并储存在`文件的metadata`中

**Class Key** :

- Complete Protection(Class A)
     (NSFileProtectionComplete): **Class Key**被passcode和UID派生的key保护,数据保护最为严格的级别，系统解锁后才能够解锁解密的密钥，并且在锁定10s以后丢弃该密钥。

- Protected Unless Open(Class B)
    (NSFileProtectionCompleteUnlessOpen): 数据保护较为严格的级别,**Class Key**由 One-Pass Diffie-Hellman Key Agreement生成,文件一但解锁后即使系统锁屏仍然可以访问，直到文件句柄被关闭

- Protected Until First User Authentication(Class C) 默认的
    (NSFileProtectionCompleteUntilFirstUserAuthentication):数据保护较为严格的级别，在系统启动时第一次输入密码时解锁解密的密钥，并且在系统关闭时丢弃密钥。

- No Protection(Class D)
    (NSFileProtectionNone):**Class Key**使用只被UID保护,并且储存在Effaceable Storage.可被安全擦除

**File System Key** 加密`文件的metadata`

**Hardware Key** 在`iOS第一次被安装`或者`设备被用户擦除`时生成,对于APFS来说,Hardware Key就是安全隔区的UID,用来封装**file system key**

**Effaceable Key** 储存在Effaceable Storage中,对`ephemeral key(file system key)`进行再次封装: `effeaceable key(ephemeral key(file system key))`, 一旦用户使用**擦除功能**,清除的就是这个 effaceable key,然后所有的文件内容都是不可读的了

架构的优点: 

修改文件的class只需要重新包装它的per-file key

修改pascode只需要重新包装它的class key

### 0x02 Passcodes

用来与Hardware key(UID)一起解密**class key**

在搭载安全隔区的设备上， 延迟由安全隔区协处理器执行。

锁屏密码(PassCode)除了防止用户进入系统桌面之外，更重要的角色就是利用密码对系统密钥包进行额外的加密保护。

用户在第一次设置锁屏密码的时候，锁屏密码会结合 **硬件加密引擎** 生成一个叫做`Passcode Key`的密钥，通过这个密钥对保存在密钥包中的各个钥匙(`Class Key`)进行加密保护。锁屏密码不会以其他加密的形式保存在设备上，用户在解锁的时候，会直接用输入的密码生成`Passcode Key`对密钥包中的`Class Key`解密，解密失败代表用户密码错误。

### 0x03 Keychain data protection




## iCloud
- iCloud会备份keychain数据吗

## keychain
- 什么时候keychain的数据会被销毁 : 比如系统还原的时候,备份的时候会备份吗?

## 专用名词

`Secure Enclave` : 安全隔区

`APFS: Apple File System format` 所有兼容的设备升级到iOS 10.3、tvOS 10.2和watchOS 3.2，会将HFS+文件系统转换为APFS。[15]有测试表明APFS不支持32位的设备，例如iPhone 5[16]。


## 问题

Secure Enclave 和application processor的关系是什么?

flash memory和磁盘是什么关系



## 借鉴的点

- app降级: 借鉴系统判断降级的方法(通过抓包可以抓到)
- 生成文件的时候设置权限
  
    ```objc
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/test.plist",NSHomeDirectory()];

    if ([[NSFileManager defaultManager] createFileAtPath:filePath contents:[@"hello world" dataUsingEncoding: NSUTF8StringEncoding] attributes:@{NSFileProtectionKey:NSFileProtectionComplete}]) {
        NSLog(@"创建成功");
        NSDictionary *fileAttrs=[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSLog(@"文件的基本信息  %@",fileAttrs);
    };
    ```
    ![SamuelChan/20181015164152.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181015164152.png)

- 在安全隔区生成密钥:kSecAttrTokenIDSecureEnclave

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



## A系列处理器对应的机型

内核与CPU的关系
内核是CPU的核心，一个CPU可以有多个内核（也就是多核处理器），而一个内核只能属于一个CPU。

芯片 | 机型 | 描述
---------|----------|---------
 [A4](https://zh.wikipedia.org/wiki/Apple_A4) | iPhone 4 | 
 [A5](https://zh.wikipedia.org/wiki/Apple_A5) | iPhone 4S | CPU提升两倍,GPU性能较前一代A4提升7倍之多
 [A6](https://zh.wikipedia.org/wiki/Apple_A6) | iPhone 5和iPhone 5c | CPU和GPU的能力比较Apple A5强劲两倍。
 [A7(从A7开始有**安全隔区**)](https://zh.wikipedia.org/wiki/Apple_A7) | iPhone 5S、iPad Air和iPad mini2 | CPU与GPU效能都是Apple A6的两倍; iPhone成为全球首款采用64位元处理器的智能手机
 [A8](https://zh.wikipedia.org/wiki/Apple_A8) | iPhone 6、iPhone 6 Plus、iPad mini 4、iPod touch 6、Apple TV和HomePod | CPU性能高25%，GPU性能高50%，能源效益高50%
 [A9](https://zh.wikipedia.org/wiki/Apple_A9) | iPhone 6S和iPhone 6S Plus | CPU性能提高了70%，而GPU性能提高了90%
 [A10](https://zh.wikipedia.org/wiki/Apple_A10_Fusion) | iPhone 7和iPhone 7 Plus | CPU性能提升了40%，在图形运算提升了50%
 [A11](https://zh.wikipedia.org/wiki/Apple_A11_Bionic) | iPhone 8、iPhone 8 Plus及iPhone X |  “仿生”（Bionic）;CPU部分高性能核心和节电核心的性能分别提升25%及70%，GPU性能较前代提升30%
 [A12](https://zh.wikipedia.org/wiki/Apple_A12_Bionic) | iPhone XS、iPhone XS Max和iPhone XR | CPU处理性能较上一代A11 Bionic提升最高约15%，节能最高达50%。
