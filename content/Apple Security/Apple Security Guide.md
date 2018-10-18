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

![SamuelChan/20181018101631.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181018101631.png)


## 一.系统安全性

### #0x00 安全启动链 (Secure Boot Chain)

> 安全启动链包括了：`引导加载程序`,`内核`,`内核扩展项`,`基带固件`, 确保硬件不被篡改

![SamuelChan/20181017201825.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181017201825.png)

开机之后,`应用程序处理器`立即执行`Boot ROM`中的代码. 其中包括 Apple 根 CA 公钥, 用来验证 `引导加载程序`是否经过 Apple 签名

这是信任链中的第一步， 信任链中的每个步骤 都确保下一步骤获得 Apple 的签名。 `引导加载程序` 完成任务后，会验证和运行 `内核`, 直到安全启动链全部验证成功

如果 `Boot ROM` 加载 `引导加载程序` 失败,则进入 **DFU Mode**

如果 `引导加载程序` 加载 `内核` 失败, 则进入** Recovery Mode**

### #0x01 系统软件验证 (System Software Authorization)

> 这个机制用来阻止设备降级, Secure Enclave(安全隔区)也能会使用这个机制

#### OTA update (Over The Air): 增量更新

#### Over USB update (using iTunes): 全量下载iOS

![SamuelChan/20181017202951.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181017202951.png)

步骤如下:

- 设备发送加密的一串设备信息(iBoot, the kernel, and OS image),nonce,ECID给 server
- server 找到设备信息对应的版本之后,将ECID加入到设备信息中,然后签名
  - 客户端用苹果的公钥验证更新是否来自苹果官方
  - 启动时`安全启动链`使用ECID验证签名是否正确并用于这台设备的

### #0x02 安全隔区

安全隔区是一个协处理器,使用加密内容;包含了一个硬件随机数生成器

安全隔区提供 **数据保护** 的密钥的`管理`;安全隔区还负责处理来自触控 ID 和面容 ID 传感器的指纹和面容数据，

安全隔区也有类似的安全启动链(Boot ROM → Secure Enclave OS) 和 安全隔区升级过程

设备启动时,安全隔区的Boot ROM会生成一个key(an ephemeral memory protection key),用来保护安全隔区的磁盘 和 内存

保存到文件系统的数据,会被安全隔区使用 **UID** 和 **反重放计数器** 生成的密钥加密

Anti-replay services on the Secure Enclave are used for revocation of data over events that mark anti-replay boundaries including, but not limited to, the following:

- Passcode change
- Touch ID or Face ID enable/disable 
- Touch ID fingerprint add/delete
- Face ID reset
- Apple Pay card add/remove
- Erase All Content and Settings

#### 密码

必须使用密码的情况

- 设备刚刚开机或重新启动。
- 设备未解锁的时间超过 48 小时。
- 在过去 156 个小时 (六天半) 内未使用密码解锁设备， 且在过去 4 小时内未使用 面容 ID 解锁设备。
- 设备收到了远程锁定命令。
- 尝试五次后未能成功匹配。
- 在关机 / 使用 SOS 紧急联络后。

#### TouchId

只有当主屏幕按钮周围的电容金属环检测到手指触摸时，指纹传感器才会启动，从而触发先进的成像阵列来扫描手指，并将扫描结果发送至安全隔区。

TouchId传感器会与安全隔区预置的共享密钥进行协商,生成一个会话密钥,它会使用 `AES-CCM` 来传输加密的TouchId扫描结果

TouchId扫描结果会在 **安全隔区** 被处理,**有损处理** 生成的节点图以一种只能由安全隔区读取的加密格式进行储存，不包含任何身份信息并且绝不会发送给 Apple 或备份至 iCloud 或 iTunes。

![SamuelChan/20181018103718.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181018103718.png)

#### FaceID

FaceId触发: 您的双眼睁开且注视着设备来确认注意力和解锁意图

一旦确认存在注意着设备的脸部，原深感摄像头会投影并读取 30000 多个红外点以绘制脸部的深度图和 2D 红外图像。此数据被用来创建一个 2D 图像和深度图序列，经过数字签名后发送到安全隔区。

FaceID数据，其中包括脸部的数学表达式，经过加密且仅可被安全隔区使用。 此数据绝对不会离开设备，不会发送给 Apple， 也不会包括在设备备份中。 在日常操作中，以下FaceID数据会存储和加密，仅供安全隔区使用 :

- 注册时，计算出的您脸部的数学表达式。

- 在某些解锁尝试过程中计算出的脸部数学表达式， 如果FaceID 认为这些表达式有助于扩增日后匹配。

#### TouchId和FaceId如何解锁你的iPhone

- 设置 TouchID 和 FaceID 前,系统要求你必须设置 passcode

- Passcode Key 被 TouchID /FaceID 子系统在Secure Enclave封装起来,即是说: TouchID /FaceID 被验证通过之后, 无需输入 passcode, 系统使用Passcode Key去解密,完成解锁

- 手机解锁完成的条件就是密钥包的所有Class Key都被正确解密

## 二.加密和数据保护（Encryption and Data Protection）

> “设置” 中的 “抹掉所有内容和设置” 选项会清除可擦除储存空间上的所有密钥， 备份可以备份储存空间上的所有密钥吗?

![SamuelChan/20181018104104.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181018104104.png)

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

在安全隔区中运行的软件利用 **UID** 来保护设备特定的密钥。**UID**可以将数据绑定到对应的设备中，例如：

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

所有的`file key` 封装 / 解封装 都发生在安全隔区内

安全隔区会使用与`AES hardware engine`协商生成的**ephemeral key**来封装目标key,保证数据保护操作对应用处理器(application processor)是透明的

文件创建 → Data Protection新建一个256位的key(**PerFile Key**)给硬件AES引擎 → 硬件AES引擎使用这个key来加密将会被写入flash memory的文件; A7之前:AES-CBC;A7之后:AES-XTS; 加密用的vector:用 **PerFile Key** 的SHA-1来加密文件的块偏移

1. **PerFile Key**被 **Class Key** 封装([NIST AES](https://tools.ietf.org/html/rfc3394)), 并储存在`文件的metadata`中

2. **Class Key** :

    - Complete Protection(Class A)
        (NSFileProtectionComplete): **Class Key**被passcode和UID派生的key保护,数据保护最为严格的级别，系统解锁后才能够解锁解密的密钥，并且在锁定10s以后丢弃该密钥。

    - Protected Unless Open(Class B)
        (NSFileProtectionCompleteUnlessOpen): 文件一但解锁后即使系统锁屏仍然可以访问，直到文件句柄被关闭

    - Protected Until First User Authentication(Class C) **文件创建时默认的的级别**
        (NSFileProtectionCompleteUntilFirstUserAuthentication):数据保护较为严格的级别，在系统启动时第一次输入密码时解锁解密的密钥，锁屏不会丢弃`Class Key`，只有在关机时才丢弃密钥。

    - No Protection(Class D)
        (NSFileProtectionNone):**Class Key**使用只被UID保护,并且储存在Effaceable Storage.可被安全擦除

3. **File System Key** 在`iOS第一次被安装`或者`设备被用户擦除`时生成,用来加密`文件的metadata`

4. **Hardware Key** 对于APFS来说,Hardware Key就是安全隔区的UID,用来封装`file system key`

5. **Passcode Key** 由 `UID` , `Passcode` 使用 `KDF` 生成

6. **Effaceable Key** 储存在Effaceable Storage中,会对`file system key`进行再次封装: `effeaceable key(file system key)`
    ![SamuelChan/20181018204600.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181018204600.png)
    一旦用户使用**擦除功能**,Effaceable storage的内容就回被全部清除


综上所述:

![SamuelChan/20181018170328.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181018170328.png)

> [Key0x89B](http://cipherbox.blogspot.com/2015/10/on-ios-firmware-and-key-decryption.html)=AES(UID,0x"183e99676bb03c546fa468f51c0cbd49") **It is used to encrypt the data partition key.**
>
> [Key0x835](http://cipherbox.blogspot.com/2015/10/on-ios-firmware-and-key-decryption.html)=AES(UID,
0x"01010101010101010101010101010101") **Used for data protection.**
> 

架构的优点: 

修改文件的class只需要重新包装它的per-file key

修改pascode只需要重新包装它的class key

### 0x02 Passcodes

用来与Hardware key(UID)一起解密 **Class Key**

在搭载安全隔区的设备上， 延迟由安全隔区协处理器执行。

锁屏密码(PassCode)除了防止用户进入系统桌面之外，更重要的角色就是利用密码对系统密钥包进行额外的加密保护。

用户在第一次设置锁屏密码的时候，锁屏密码会结合 **硬件加密引擎** 生成一个叫做`Passcode Key`的密钥，通过这个密钥对保存在密钥包中的各个钥匙(`Class Key`)进行加密保护。锁屏密码不会以其他加密的形式保存在设备上，用户在解锁的时候，会直接用输入的密码生成`Passcode Key`对密钥包中的`Class Key`解密，解密失败代表用户密码错误。

### 0x03 Keychain data protection

- 什么时候keychain的数据会被销毁 : 比如系统还原的时候,备份的时候会备份吗?
- 钥匙串储存在哪里
- 安全性怎么保障
- 钥匙串的item与添加时的touchId,faceId

![2333333333](https://docs-assets.developer.apple.com/published/0ddea9db46/1c9e8103-fae2-45f4-832c-c528d2e0c2f6.png)

1. KeyChain储存在文件系统中,用**SQLite**数据库来实现的

2. 每个KeyChain item使用两个的 AES-256-GCM key 来加密: meta-data key 和 secret key 均保存在Secure Enclave处理器中
    ![sdfsdf](https://upload-images.jianshu.io/upload_images/143867-7f829bc6692d5677.jpg)
    - meta-data key 用来加密 meta-data (除了kSecValue)
    - secret key 加密 kSecValueData

3. Keychain的组成
    ![SamuelChan/20181018204756.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181018204756.png)
    - 加密的数据
        - Version number
        - ACL data
        - KeychainItem 的数据保护级别 class
        - protection class key (per-item key)
        - per-item 加密的钥匙串所有属性
    - 所有属性的SHA-1 hashes,用于快速查询

4. Keychain运行在 `securityd daemon`

5. “Keychain-access-groups,” “application-identifier,” and “application-group” entitlements.

6. Keychain ACL控制 : 访问钥匙串需要Touch ID,Face ID,输入 passcode. ACL 是在 Secure Enclave 中进行的

7. Keychain data保护级别类似 File data protection

Availability | File Data Protection | Keychain Data Protection
---------|----------|---------
 When unlocked | NSFileProtectionComplete | kSecAttrAccessibleWhenUnlocked
 While locked | NSFileProtectionCompleteUnlessOpen | N/A
 After first unlock | NSFileProtectionCompleteUntilFirstUserAuthentication | kSecAttrAccessibleAfterFirstUnlock
 Always | NSFileProtectionNone | kSecAttrAccessibleAlways
 Passcode enabled | N/A | kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly

- `kSecAttrAccessibleAfterFirstUnlock` 可以用于后台刷新
- `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`与`kSecAttrAccessibleWhenUnlocked`功能一样,但是使用`kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`时,设备必须设置了passcode; 如果 passcode 被移除或者是重置,这些keychain项将无法访问
  - 不会被同步到iCloud keychain
  - 不会被备份
  - 不会被包含在escrow keybag中
- Other Keychain classes have a “This device only” counterpart, which is always protected with the UID when being copied from the device during a backup, rendering it useless if restored to a different device.
    ```objc
    typedef NS_ENUM(NSInteger, UICKeyChainStoreAccessibility) {
        UICKeyChainStoreAccessibilityWhenUnlocked = 1,
        UICKeyChainStoreAccessibilityAfterFirstUnlock,
        UICKeyChainStoreAccessibilityAlways,
        UICKeyChainStoreAccessibilityWhenPasscodeSetThisDeviceOnly
        __OSX_AVAILABLE_STARTING(__MAC_10_10, __IPHONE_8_0),
        UICKeyChainStoreAccessibilityWhenUnlockedThisDeviceOnly,
        UICKeyChainStoreAccessibilityAfterFirstUnlockThisDeviceOnly,
        UICKeyChainStoreAccessibilityAlwaysThisDeviceOnly,
    }
    ```

Item |  Accessible|
---------|----------|
 Wi-Fi passwords | After first unlock |
 Mail accounts | After first unlock |
 Exchange accounts | After first unlock |
 VPN passwords | After first unlock |
 Exchange accounts | After first unlock |
 LDAP, CalDAV, CardDAV | After first unlock |
 Social network account tokens | After first unlock |
 Handoff advertisement encryption keys | After first unlock |
 iCloud token | After first unlock |
 Home sharing password | When unlocked |
 Find My iPhone token | Always |
 Voicemail | Always |
 iTunes backup | When unlocked, non-migratory |
 Safari passwords | When unlocked |
 Safari bookmarks | When unlocked |
 VPN certificates | Always, non-migratory |
 Bluetooth keys | Always, non-migratory |
 Apple Push Notification service (APNs) token | Always, non-migratory |
 iCloud certificates and private key | Always, non-migratory |
 iMessage keys | Always, non-migratory |
 Certificates and private keys installed by a configuration profile | Always, non-migratory |
 SIM PIN | Always, non-migratory |



### 0x04 KeyBag 密钥包

> `密钥包`储存和管理`文件`和`钥匙串`相关数据保护类型的密钥(被加密过后的**class Key**)

iOS有以下几种密钥包

1. User KeyBag : 用户相关的 class Keys
    - User KeyBag 是一个 class D(No Protection class)二进制 .plist 文件,文件内容被 Effaceable Storage 的 **BAG1** 保护,用来加密/解密 KeyBag (每次修改 passcode ,这个 **BAG1** 都会重新生成)
    - User KeyBag 由 AppleKeyStore(kernel extension)来管理
    - 只有密钥包的所有 Class Keys 都被解封装,设备才会解锁

2. Device KeyBag : 设备相关数据的 class Keys
    - 由于 iOS 设备是单用户,所以 **Device KeyBag 和 User KeyBag 是同一个**

3. BackUp KeyBag : 在电脑上使用iTunes备份手机时创建
    - KeyBag使用一串新的key来加密备份数据
    - non-migratory Keychain items依然还是使用 UID-derived key 封装,在其他设备不能恢复
    - Keychain item只有在设置了 backup password 之后,才可以迁移到新的设备上.

4. Escrow KeyBag : 用于 iTunes 同步和 MDM
    - One-time Unlock Tokens
 
5. iCloud Backup KeyBag : 所有的 class Keys 都是 class B(Protected Unless Open Data Protection class)
    - iCloud需要在后台备份
    - 苹果为每一个iCloud用户生成一对公私钥,上传 iCloud Backup KeyBag 的时候,使用公钥加密

## 应用安全

### # 0x00 应用代码签名

使用Apple颁发的证书（开发者计划）来签名应用代码

### # 0x01 运行时进程安全性

所有第三方应用均已经过 “沙盒化”(**以非权限用户"mobile”的身份运行**)， 因此它们在访问其他应用储存的文件或对设备进行更改时会受到限制。系统文件和资源也会与用户的应用保持隔离。

### # 0x02 应用中的数据保护

`Data Protection`适用于文件和数据库 API， 包括 NSFileManager、 CoreData、 NSData 和 SQLite。

用户安装的应用若没有选择加入某个特定数据保护类， 则默认接受 “首次用户认证前保护”。

## 通信安全

### #0x00 iCloud

每个文件都被分成 chunks, 并由 iCloud 使用 AES-128 以及从利用 SHA-256 的每个 chunk 内容派生的密钥进行加密。 密钥和文件的 meta data 由 Apple 储存在用户的 iCloud 帐户中。 文件的加密 chunks 通过第三方的存储服务 (例如 S3 和 Google 云平台) 进行储存， 不带任何用户识别信息。

#### iCloud Drive

iCloud Drive 使用了 account-based keys 来保护存放在 iCloud 的文档

加密 chunks 的密钥使用 record keys 封装, 然后再使用用户的 iCloud Drive Service Key 来封装

要访问 iCloud Drive 的 文件, 用户必须先登录上 iCloud , 并且同时拥有iCloud Drive key

#### CloudKit

`CloudKit` 是 Apple 提供给开发者用来储存 key-value 数据, structured 数据, asset 到 iCloud 中，支持公共数据库和私有数据库

![SamuelChan/20181017155104.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20181017155104.png)

#### CloudKit end-to-end 加密

Apple Page Cash,Health data,User keywords,Siri 使用 CloudKit Service Key 进行 CloudKit 端对端加密, 该密钥受 iCloud 钥匙串同步的保护。对于这些 CloudKit 容器， 密钥层次结构植根于 iCloud 钥匙串， 因此享有 iCloud 钥匙串的安全性特性 : 密钥仅可在用户受信任的设备上使用， Apple 或任何第三方都无法使用。

#### iCloud 备份


### # 0x01 iCloud Keychain

> 隐私，安全，易用，可恢复

#### iCloud syncing

当用户第一次打开 iCloud KeyChain, 设备会创建：

- syncing identity
  - a privete key
  - a public key
- circle of trust(信任圈)

syncing identity的公钥放置在信任圈中， 然后该信任圈已签名两次 : 第一次由同步 身份的私钥签署， 第二次由来自用户 iCloud 帐户密码的非对称椭圆密钥 (使用 P-256) 签名。 随信任圈一起储存的还有参数 (随机盐密钥和迭代次数)， 用于创建基于用户 iCloud 密码的密钥。

已签名的同步信任圈放置在用户的 iCloud 密钥值存储区域。 如果不知道用户的 iCloud 密码， 就无法对其进行读取 ; 如果没有信任圈成员 syncing identity 的私钥， 就无法对其进行有效地修改。

当用户在其他设备上启用 iCloud 钥匙串时， 新设备会注意到该用户之前在 iCloud 中建立过同步信任圈， 但本设备不是该信任圈的成员。 该设备将创建其`syncing identity`密钥对， 然后创建应用程序申请单以请求加入该信任圈。 该申请单包括设备的`syncing identity`公钥， 系统将要求用户使用其 iCloud 密码进行认证。 椭圆密钥生成参数通过 iCloud 取回， 并生成用于签名应用程序申请单的密钥。 最终， 应用程序申请单将放置在 iCloud 中。

当第一台设备接收到应用程序申请单时，它会显示一则通知， 让用户确认新设备正在请求加入同步信任圈。 该用户输入其 iCloud 密码， 应用程序申请单通过匹配的私钥签名进行验证。 这样即确认发出请求加入信任圈的人在发出请求时输入了用户的 iCloud 密码。

用户批准将新设备添加至信任圈后，第一台设备将新成员的公钥添加至同步信任圈，使用其同步身份和来自用户 iCloud 密码的密钥再次签名。新的同步信任圈放置在 iCloud 中，该信任圈的新成员同样进行了签名。

现在，签名信任圈有两个成员，并且每个成员拥有另一个成员的公钥。它们现在开始通过 iCloud 键值储存交换各个钥匙串项或视情况将其储存在 CloudKit 中。如果两个信任圈 成员拥有相同的项目，修改日期最近的项目将被同步。如果另一个成员拥有该项目并且修改日期相同，这些项目将被跳过。 每个同步的项目都会加密，因此只有用户信任圈内的设 备才能解密。任何其他设备或 Apple 均无法解密。

但是，整个钥匙串不会进行同步。某些项目仅限于特定的设备 (例如 VPN 身份)，它们不应该离开设备。仅具有 kSecAttrSynchronizable 属性的项目会被同步。 Apple 已经为 Safari 浏览器用户数据 (包括用户名、 密码和信用卡号)、无线局域网密码以及 HomeKit 加密密钥设置了该属性。

另外，在默认情况下，第三方应用添加的钥匙串项不会进行同步。将项目添加至钥匙串时，开发者必须设置 kSecAttrSynchronizable。

#### iCloud recovery

#### Escrow security

### 0x02 iMessages

## 专用名词

`Secure Enclave` : 安全隔区

`APFS: Apple File System format` 所有兼容的设备升级到iOS 10.3、tvOS 10.2和watchOS 3.2，会将HFS+文件系统转换为APFS。[15]有测试表明APFS不支持32位的设备，例如iPhone 5[16]。

## 问题

Secure Enclave 和application processor的关系是什么?

## 借鉴的点

- app降级: 借鉴系统判断降级的方法(通过抓包可以抓到app store老版本的安装包)
- 生成文件的时候设置权限,适用于`NSFileManager`、 `CoreData`、 `NSData` 和 `SQLite`,尽可能的使用classes A and B.
  
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

- 钥匙串
  - 使用钥匙串来储存机密信息,应用生成私钥的item属性应该为non-migratory
  - Keychain-access_group多个app可以共享钥匙串
  - ACL
  - 设置keychain items的级别 + this device only (kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
  - kSecAccessControlTouchIDCurrentSet : 该钥匙串项只能通过当前的TouchId来访问,如果TouchId被销毁/更改,那么这个钥匙串项就不能访问

- iCloud KeyChain 同步机制

...to be continued

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


## 参考资料

[iOS Security Part 1 - Secure Boot](http://sebastienduc.blogspot.com/2016/03/ios-security-part-1-secure-boot.html?view=magazine)

[How the Secure Enclave & Touch ID Work - Apple iOS Security - Part 1 of 6](https://www.youtube.com/watch?v=vTNm85H49x8)

[Apple iOS application development guidance](https://www.ncsc.gov.uk/guidance/apple-ios-application-development-guidance-0#3)

[iOS 10: How to Use Secure Enclave and Touch ID to Protect your Keys](https://www.linkedin.com/pulse/ios-10-how-use-secure-enclave-touch-id-protect-your-keys-satyam-tyagi)

[Decrypting iOS Firmware and AES Derived Keys (iOS 8.3 on iPhone6) ---- keybag](http://cipherbox.blogspot.com/2015/10/on-ios-firmware-and-key-decryption.html)

[A (not-so-quick) Primer on iOS Encryption David Schuetz - NCC Group](https://www.slideshare.net/EC-Council/a-notsoquick-primer-on-ios-encryption-david-schuetz-ncc-group)

