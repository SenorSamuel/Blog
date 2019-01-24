# KeyChain安全机制与基本使用

> [KeyChain](https://developer.apple.com/documentation/security/keychain_services?language=objc) Securely store **small** chunks of data on behalf of the user.

![SamuelChan/20181026155919.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181026155919.png)

## Keychain 的安全性

    1. Keychain 储存在哪里?

   Keychain 是用 SQL 数据库来实现的，储存在**文件系统**中

    2. Keychain 数据是如何被加密

根据 Apple 安全白皮书,一个 Keychain item 按照如下结构加密的：

- Keychain item 由 timeStamp,SHA-1 Hashes(用于快速查询)，加密数据（128GCM）组成
- 其中`加密数据`的结构如下：
  - Version
  - ACL
  - Class Type
  - 被 Class Key加密的 per-item Key
  - 由 per-item Key加密的 attributes，attributes 是 SecItemAdd传入的属性字典
    - kSecValueData 由 Secure Enclave 中的一把 secret key 加密
    - 其他的attrs(kSecClass,kSecAttrAccount,kSecAttrService...)由 Secure Enclave 中的一把 meta-data key 加密

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181221163517.png)


    3. 系统 Keychain 和 应用的 Keychain

系统 Keychain 在 iOS 中是在 `设置` → `密码与账户` → `网站与应用密码`

应用 Keychain 的访问权限是根据 `Keychain-access-groups,` `application-identifier,` and `application-group entitlements` 来确定的：

- 在同一个 KeychainGroup 中，不同应用的 Keychain 能相互访问
- 仅仅使用相同的 bundleID，是无法访问原本应用的 Keychain 的

```objc
应用的 Keychain 删除 app 之后还会存在
```

之前盛传 `10.3` 之后会改，在 `iOS 12`上面测试，app 删除之后，应用 Keychain 不会被删除

    4. Keychain 什么时候会被清除

由于 Keychain 被储存在文件系统中，所以任何清空文件系统的都会删除 Keychain，比如：擦除设备

Keychain 储存在文件系统中，所以擦除设备或者是远程擦除（加密文件系统的密钥被擦除）可以让 Keychain 删除/不可访问


    5. 越狱之后原本的 Keychain 数据安全吗？

不安全，可以使用 [Keychain-Dumper](https://github.com/ptoomey3/Keychain-Dumper) 可以导出 Keychain 的数据

根据 [这个答案](https://forums.developer.apple.com/thread/36442)，建议如果开发者希望删除 app 之后应用 Keychain 不能被访问，取巧的方式可以在用一个 Key 来加密保存到 Keychain 之前的数据，这样 App 被删除之后那些数据就无法被解密。

## Keychain Items

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181211170430.png)

- 没有设置 ACL 的 Keychain item 过程：

    - 使用 `Key management` 来解密 `Keychain item`.

- 设置了 ACL 的 Keychain item 过程：
    - ACL 依赖于 `Security.framework` 和 `LocalAuthentication.frameworks`，`LocalAuthentication.frameworks` 通过 `Secure Enclave` 中的 `Credential management` 来验证 `Biometry`, 如果校验通过，就使用 `Key management` 来解密 `Keychain item`.


<!-- 使用KeyChain储存互联网应用密码的流程如下:

![SamuelChan/20181026172714.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181026172714.png)

- 先查找 Keychain 中有没有该 item,如果没有，那么就使用 SecItemAdd 来新增
- 如果找到了并且验证成功就直接返回
- 验证失败，调用 SecItemUpdate 来更新 -->

使用 `Security.framework` 中的 `SecItem.h`的四个方法来对钥匙串进行**增、删、改、查**

```objc
OSStatus SecItemAdd(CFDictionaryRef attributes, CFTypeRef * __nullable CF_RETURNS_RETAINED result)
OSStatus SecItemDelete(CFDictionaryRef query)
OSStatus SecItemUpdate(CFDictionaryRef query, CFDictionaryRef attributesToUpdate)
OSStatus SecItemCopyMatching(CFDictionaryRef query, CFTypeRef * __nullable CF_RETURNS_RETAINED result)
```


### 0x00 新增Keychain item

```objc
//增
OSStatus SecItemAdd(CFDictionaryRef attributes, CFTypeRef  _Nullable *result);
//attributes : 常用的属性含括四方面
    //a. kSecClass : 告诉 Keychain 是密码,证书,密钥等
    //b. kSecValueRef : Keychain 会根据 kSecClass 判断是否加密 value
    //c. 可选属性 : kSecAttrAccount，kSecAttrService，kSecAttrServer等
    //d. 可选返回属性 : 操作成功之后,需要在（result）中返回什么数据; SecItemAdd不需要
//result : 根据 （d.）中属性来返回, 如果不需要,传 NULL
//返回值 : 操作成功、失败的信息

    NSDictionary *query = @{
                            (__bridge __strong id)kSecClass : (__bridge id)kSecClassGenericPassword,
                            (__bridge __strong id)kSecAttrAccount : @"Samuel",
                            (__bridge __strong id)kSecAttrService : @"samuel.testKeychain.com",
                            (__bridge __strong id)kSecValueData : [@"passwordOfSamuel" dataUsingEncoding:NSUTF8StringEncoding],
                            (__bridge __strong id)kSecAttrAccessControl : (__bridge_transfer id)aclRef
                            };
    OSStatus sanityCheck = SecItemAdd((__bridge CFDictionaryRef)(query), NULL);
```

### 0x01 kSecClass的类型

Keys | Value | Comment
:---------:|----------|---------
 kSecClass | kSecClassGenericPassword | a genneric password
-  | kSecClassInternetPassword | an Internet password item.(**kSecAttrServer**)
-  | kSecClassCertificate | a certificate item.
-  | kSecClassKey | a cryptographic key item.
-  | kSecClassIdentity | An identity = certificate + private key. 包含了 **kSecClassKey** 和 **kSecClassCertificate** 中的可用属性

每个 kSecClass 可以使用的 `attributes` 是不一样的，详情如下:

```objc
    * kSecClassGenericPassword item attributes:
        kSecAttrAccess (OS X only)
        kSecAttrAccessControl
        kSecAttrAccessGroup (iOS; also OS X if kSecAttrSynchronizable specified)
        kSecAttrAccessible (iOS; also OS X if kSecAttrSynchronizable specified)
        kSecAttrCreationDate
        kSecAttrModificationDate
        kSecAttrDescription
        kSecAttrComment
        kSecAttrCreator
        kSecAttrType
        kSecAttrLabel
        kSecAttrIsInvisible
        kSecAttrIsNegative
        kSecAttrAccount
        kSecAttrService
        kSecAttrGeneric
        kSecAttrSynchronizable

    * kSecClassInternetPassword item attributes:
        kSecAttrAccess (OS X only)
        kSecAttrAccessControl
        kSecAttrAccessGroup (iOS; also OS X if kSecAttrSynchronizable specified)
        kSecAttrAccessible (iOS; also OS X if kSecAttrSynchronizable specified)
        kSecAttrCreationDate
        kSecAttrModificationDate
        kSecAttrDescription
        kSecAttrComment
        kSecAttrCreator
        kSecAttrType
        kSecAttrLabel
        kSecAttrIsInvisible
        kSecAttrIsNegative
        kSecAttrAccount
        kSecAttrSecurityDomain
        kSecAttrServer
        kSecAttrProtocol
        kSecAttrAuthenticationType
        kSecAttrPort
        kSecAttrPath
        kSecAttrSynchronizable

    * kSecClassCertificate item attributes:
        kSecAttrAccessible    (iOS only)
        kSecAttrAccessControl (iOS only)
        kSecAttrAccessGroup   (iOS only)
        kSecAttrCertificateType
        kSecAttrCertificateEncoding
        kSecAttrLabel
        kSecAttrSubject
        kSecAttrIssuer
        kSecAttrSerialNumber
        kSecAttrSubjectKeyID
        kSecAttrPublicKeyHash
        kSecAttrSynchronizable

    * kSecClassKey item attributes:
        kSecAttrAccess (OS X only)
        kSecAttrAccessControl
        kSecAttrAccessGroup (iOS; also OS X if kSecAttrSynchronizable specified)
        kSecAttrAccessible (iOS; also OS X if kSecAttrSynchronizable specified)
        kSecAttrKeyClass
        kSecAttrLabel
        kSecAttrApplicationLabel
        kSecAttrIsPermanent
        kSecAttrApplicationTag
        kSecAttrKeyType
        kSecAttrPRF    (OS X only)
        kSecAttrSalt   (OS X only)
        kSecAttrRounds (OS X only)
        kSecAttrKeySizeInBits
        kSecAttrEffectiveKeySize
        kSecAttrCanEncrypt
        kSecAttrCanDecrypt
        kSecAttrCanDerive
        kSecAttrCanSign
        kSecAttrCanVerify
        kSecAttrCanWrap
        kSecAttrCanUnwrap
        kSecAttrSynchronizable
```

### 0x02 kSecAttrXXX

Keys | Value | Comment
---------|----------|---------
**General Item** |   |
kSecAttrAccess |  | macOS only
kSecAttrAccessControl | SecAccessControlCreateWithFlags(...) | 访问控制,与kSecAttrAccess是互斥的
kSecAttrAccessible|a. `.WhenPasscodeSetThisDeviceOnly`:本设备解锁之后 + 设置了passcode <br>b. `.WhenUnlockedThisDeviceOnly`:本设备解锁之后<br>c. `.WhenUnlocked`:设备解锁之后<br>d. `.AfterFirstUnlockThisDeviceOnly`:本设备第一次解锁之后<br>e. `.AfterFirstUnlock`:设备第一次解锁之后<br>f. `.AlwaysThisDeviceOnly`:本设备随时可以访问<br>g. `kSecAttrAccessibleAlways`:随时可以访问|(1) 在macOS上面必须配合`kSecAttrSynchronizable`使用<br> (2) 如果iOS,macOS同时设置这两个属性Key,那么Value就只能是除了`ThisDeviceOnly`之外的值
kSecAttrAccessGroup|CFStringRef|不设置时,App默认使用AppID作为entitlement去Keychain找
kSecAttrSynchronizable|kSecAttrSynchronizableAny : 可同步的/不可同步的全部返回| 作用: 能否通过iCloud来同步item<br>a. 添加/修改时value是true/false,查询时true/false/kSecAttrSynchronizableAny  <br> b. 修改之后,所有设备保持同步 <br> c. **只对密码起作用,对证书/密钥无效** <br> d.......略(后面再补充,这里跟iCloud搅和在一起了...吐血)
kSecAttrCreationDate|CFStringRef|
kSecAttrModificationDate|CFStringRef|
kSecAttrDescription|CFStringRef|
kSecAttrComment|CFStringRef|
kSecAttrCreator|CFStringRef|
kSecAttrType|CFStringRef| unsigned int 4位 (for example `aTyp`)
kSecAttrLabel|CFStringRef| 默认NULL
kSecAttrIsInvisible|CFBooleanRef| 是否隐藏
kSecAttrIsNegative|CFBooleanRef| item的密码是否有效
kSecAttrSyncViewHint|| iOS 9
kSecAttrPersistantReference||iOS 11
kSecAttrPersistentReference||iOS 11
**Password**||
kSecAttrAccount|CFStringRef| account Name
kSecAttrService|CFStringRef|
kSecAttrGeneric|CFDataRef|用户定义属性
kSecAttrSecurityDomain|CFStringRef|Internet security domain
kSecAttrServer|CFStringRef| item's server
kSecAttrProtocol|kSecAttrProtocolFTP<br>kSecAttrProtocolFTPAccount<br>kSecAttrProtocolHTTP<br>kSecAttrProtocolIRC<br>kSecAttrProtocolNNTP<br>kSecAttrProtocolPOP3<br>kSecAttrProtocolSMTP<br>kSecAttrProtocolSOCKS<br>kSecAttrProtocolIMAP<br>kSecAttrProtocolLDAP<br>kSecAttrProtocolAppleTalk<br>kSecAttrProtocolAFP<br>kSecAttrProtocolTelnet<br>kSecAttrProtocolSSH<br>kSecAttrProtocolFTPS<br>kSecAttrProtocolHTTPS<br>kSecAttrProtocolHTTPProxy<br>kSecAttrProtocolHTTPSProxy<br>kSecAttrProtocolFTPProxy<br>kSecAttrProtocolSMB<br>kSecAttrProtocolRTSP<br>kSecAttrProtocolRTSPProxy<br>kSecAttrProtocolDAAP<br>kSecAttrProtocolEPPC<br>kSecAttrProtocolIPP<br>kSecAttrProtocolNNTPS<br>kSecAttrProtocolLDAPS<br>kSecAttrProtocolTelnetS<br>kSecAttrProtocolIMAPS<br>kSecAttrProtocolIRCS<br>kSecAttrProtocolPOP3S<br>|
kSecAttrAuthenticationType|kSecAttrAuthenticationTypeNTLM<br>kSecAttrAuthenticationTypeMSN<br>kSecAttrAuthenticationTypeDPA<br>kSecAttrAuthenticationTypeRPA<br>kSecAttrAuthenticationTypeHTTPBasic<br>kSecAttrAuthenticationTypeHTTPDigest<br>kSecAttrAuthenticationTypeHTMLForm<br>kSecAttrAuthenticationTypeDefault<br>|
kSecAttrPort| CFNumberRef |
kSecAttrPath| CFStringRef| Example: /mainPage/liveFeed
**Certificate Attribute Keys**||
kSecAttrSubject|CFDataRef| a. Read only<br>b. 证书的X.500主体名
kSecAttrSubjectKeyID|CFDataRef|a. Read only<br>b. 证书的主体ID
kSecAttrSerialNumber|CFDataRef|a. Read only<br>b. 序列号
kSecAttrIssuer|CFDataRef|a. Read only<br>b. X.500颁发名
kSecAttrPublicKeyHash|CFDataRef|a. Read only<br>b. 证书公钥的hash
kSecAttrCertificateType|CSSM_CERT_UNKNOWN<br>CSSM_CERT_X_509v1<br>CSSM_CERT_X_509v2        <br>CSSM_CERT_X_509v3<br>CSSM_CERT_Fortezza<br>CSSM_CERT_PGP<br>CSSM_CERT_SPKI<br>CSSM_CERT_SDSIv1<br>CSSM_CERT_Intel<br>CSSM_CERT_ATTRIBUTE_BER<br>CSSM_CERT_X509_CRL<br>CSSM_CERT_LAST|Read only
kSecAttrCertificateEncoding|CSSM_CERT_ENCODING_UNKNOWN<br>CSSM_CERT_ENCODING_CUSTOM<br>CSSM_CERT_ENCODING_BER<br>CSSM_CERT_ENCODING_DER<br>CSSM_CERT_ENCODING_NDR|Read only
**Cryptographic Key**||
kSecAttrKeyClass|a. kSecAttrKeyClassPublic : 密钥对的公钥<br>b. kSecAttrKeyClassPrivate : 密钥对的私钥<br>c. kSecAttrKeyClassSymmetric : 对称加密的私钥(ps:私钥加密,所以佳作对称加密)
kSecAttrApplicationLabel|CFStringRef| 与kSecAttrLabel不同,是用于**程序**查找钥匙串,对于kSecAttrKeyClassPublic 和 kSecAttrKeyClassPrivate == 公钥的Hash
kSecAttrApplicationTag|CFDataRef|
kSecAttrKeyType|kSecAttrKeyTypeRSA<br>kSecAttrKeyTypeEC(iOS4.0+)<br>kSecAttrKeyTypeECSECPrimeRandom == kSecAttrKeyTypeEC(iOS10+)|
kSecAttrPRF|kSecAttrPRFHmacAlgSHA1<br>kSecAttrPRFHmacAlgSHA224<br>kSecAttrPRFHmacAlgSHA256<br>kSecAttrPRFHmacAlgSHA384<br>kSecAttrPRFHmacAlgSHA512| item的伪随机函数
kSecAttrSalt|CFDataRef|item的Salt
kSecAttrRounds|CFNumberRef|运行kSecAttrPRF的次数
kSecAttrKeySizeInBits|CFNumberRef| 密钥的位数
kSecAttrEffectiveKeySize|CFNumberRef|密钥有效的位数,比如: DES密钥有64位,但是有效位数只有56位
kSecAttrTokenID|kSecAttrTokenIDSecureEnclave<br>a. 将密钥储存在Secure Enclave<br>b. 只支持`kSecAttrKeyTypeEC`的密钥类型;`kSecAttrKeySizeInBits`必须为256位;<br>| a. **重新**指定生成key储存的地方,默认是生成在Keychain<br>b. 一旦生成了不能更改地方<br>c. 不能在kSecPrivateKeyAttrs or kSecPublicKeyAttrs再设置
**Cryptographic Key Usage** ||
kSecAttrIsPermanent| CFBooleanRef|密钥/密钥对是否在创建时就储存在钥匙串中,默认是 `kCFBooleanFalse`
kSecAttrIsSensitive|CFBooleanRef|设置为YES,item **export**时一定是加密格式
kSecAttrIsExtractable|CFBooleanRef|item是否可以导出
kSecAttrCanEncrypt|CFBooleanRef|密钥是否可以加密数据,默认: 私钥为kCFBooleanFalse,公钥为kCFBooleanTrue
kSecAttrCanDecrypt|CFBooleanRef|密钥是否可以解密数据,默认: 私钥为kCFBooleanTrue,公钥为kCFBooleanFalse
kSecAttrCanDerive|CFBooleanRef|密钥是否可以**derive**;默认是kCFBooleanTrue
kSecAttrCanSign|CFBooleanRef|密钥是否可以签名,默认: 私钥为kCFBooleanTrue,公钥为kCFBooleanFalse
kSecAttrCanVerify|CFBooleanRef|密钥是否可以验证签名,默认: 私钥为kCFBooleanFalse,公钥为kCFBooleanTrue
kSecAttrCanWrap|CFBooleanRef|密钥是否可以wrap另一个key,默认: 私钥为kCFBooleanFalse,公钥为kCFBooleanTrue
kSecAttrCanUnwrap|CFBooleanRef|密钥是否可以unwrap另一个key,默认:私钥为kCFBooleanTrue,公钥为kCFBooleanFalse

### 0x03 查/更新/删除 Keychain item

> 根据传入的查找参数来查找字典

```objc
//query : 常用的query包括以下四方面:
    //a. kSecClass : item 是密码/证书/密钥等
    //b. item属性
    //c. 搜索属性 : 限制搜索结果 kSecMatchLimit
    //d. 可选返回属性 : 一个或者多个返回值类型,item’s attributes, the item’s data, a reference to the data, a persistent reference to the data, or a combination of these
//result : 根据 d.中属性来返回, 如果不需要,传NULL
//返回值 : OSStatus
OSStatus SecItemCopyMatching(CFDictionaryRef query, CFTypeRef  _Nullable *result);
    //查找钥匙串中kSecClass = kSecClassGenericPassword，kSecAttrService =
    //@"samuel.testKeychain.com"，查找前需要验证身份(创建时设置的ACL)，kSecMatchLimitOne返回来第
    //一条符合搜索条件的记录，kSecUseAuthenticationContext可以把LAContext存放起来，下次就不需要验证
    NSDictionary *query = @{
                            (__bridge __strong id)kSecClass : (__bridge id)kSecClassGenericPassword,
                            (__bridge __strong id)kSecAttrService : @"samuel.testKeychain.com",
                            (__bridge __strong id)kSecReturnData:@(YES),
                            (__bridge __strong id)kSecReturnAttributes:@(YES),
                            (__bridge __strong id)kSecMatchLimit:(__bridge id)kSecMatchLimitOne,
                            (__bridge __strong id)kSecUseOperationPrompt : @"验证你的身份",
                            (__bridge __strong id)kSecUseAuthenticationContext:self.context
                            };

    CFTypeRef ref = NULL;
    //打印返回的item对象
    NSDictionary *dict = (__bridge_transfer NSDictionary *)ref;
    NSLog(@"%@", dict);
//    {
//        accc = "<SecAccessControlRef: 0x280ff2ea0>";
//        acct = Samuel;
//        agrp = "U4TFFP6YD3.com.feiyu.SecurityDemo";
//        cdat = "2018-12-21 09:58:09 +0000";
//        mdat = "2018-12-21 09:58:22 +0000";
//        musr = <>;
//        pdmn = ak;
//        persistref = <>;
//        sha1 = <89d35aef cab530c7 b69041e6 f5915ffb a737f9c6>;
//        svce = "samuel.testKeychain.com";
//        sync = 0;
//        tomb = 0;
//        "v_Data" = <6e657770 61737377 6f7264>;
//    }
    //获取其中的SecItemValue
    NSString *passwordData = [[NSString alloc]initWithData:dict[@"v_Data"] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",passwordData);

=============================================================================
//更新Keychain item
=============================================================================
OSStatus SecItemUpdate(CFDictionaryRef query, CFDictionaryRef attributesToUpdate)
    NSDictionary *query = @{
                            (__bridge __strong id)kSecClass : (__bridge id)kSecClassGenericPassword,
                            (__bridge __strong id)kSecAttrAccount : @"Samuel",
                            (__bridge __strong id)kSecAttrService : @"samuel.testKeychain.com",
                            };

    NSDictionary *updateAttributesDict = @{
                                           (__bridge __strong id)kSecValueData:[@"newpassword" dataUsingEncoding:NSUTF8StringEncoding]
                                           };

    OSStatus sanityCheck = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateAttributesDict);

=============================================================================
//删除Keychain item
=============================================================================
    NSDictionary *query = @{
                            (__bridge __strong id)kSecClass : (__bridge id)kSecClassGenericPassword,
                            (__bridge __strong id)kSecAttrAccount : @"Samuel",
                            (__bridge __strong id)kSecAttrService : @"samuel.testKeychain.com",
                            };

    OSStatus sanityCheck = SecItemDelete((__bridge CFDictionaryRef)query);
```

### 0x04 搜索 item 可用的属性

> 用于 SecItemCopyMatching, SecItemUpdate, or SecItemDelete 函数

Keys | Value | Comment
:---------:|----------|---------
**Item Search Matching Keys**||
kSecMatchPolicy|SecPolicyRef<br>比如:SecPolicyCreateBasicX509|item的certificate/identity必须通过什么策略来验证
kSecMatchItemList|同一数据类型的CFArray|只会在这些items列表中查找
kSecMatchSearchList|CFArrayRef of SecKeychainRef items|在指定的Keychain中查找
kSecMatchIssuers|CFArrayRef的数组,元素CFDataRef的X.500机构名字|返回的`certificates `or `identities`的证书链必须包含数组中的`issuers`的任意一个
kSecMatchEmailAddressIfPresent||
kSecMatchEmailAddressIfPresent|an RFC822 email address(CFStringRef)|`certificates `or `identities`必须包含该email,或者不存在email
kSecMatchSubjectContains| CFStringRef|返回`certificates `or `identities`必须**包含**着这个Subject字符串
kSecMatchSubjectStartsWith|CFStringRef|返回`certificates `or `identities`必须以这个Subject字符串开头
kSecMatchSubjectEndsWith|CFStringRef|返回`certificates `or `identities`必须以这个Subject字符串结尾
kSecMatchSubjectWholeString|CFStringRef|返回`certificates `or `identities`必须正是这个字符串
kSecMatchCaseInsensitive|CFBooleanRef|默认是false,即大小写敏感
kSecMatchDiacriticInsensitive|CFBooleanRef|默认是false,即diacritic敏感
kSecMatchWidthInsensitive|CFBooleanRef|ASCII与UTF-8(U+FF41)不匹配,默认是kCFBooleanFalse
kSecMatchTrustedOnly|CFBooleanRef|kCFBooleanTrue:被信任anchor的`certificates`才能被返回;<br>kCFBooleanFalse:信任和不被信任的`certificates`都会返回
kSecMatchValidOnDate|CFDateRef|certificates or identities在给点日期前是有效的<br>当前日期传kCFNull
kSecMatchLimit|kSecMatchLimitOne<br>kSecMatchLimitAll|默认是function-dependent
**Additional Item Search Keys**||
kSecUseOperationPrompt|CFStringRef|验证时,提示用户的字符串,一般用于查Keychain使用
kSecUseAuthenticationUI|kSecUseAuthenticationUIAllow<br>kSecUseAuthenticationUIFail<br>kSecUseAuthenticationUISkip|默认是kSecUseAuthenticationUIAllow,iOS9+
kSecUseAuthenticationContext|LAContext|iOS9+<br>a.如果没有指定这个key,那么每次都使用新的context<br>b.如果指定这个key,且context没有被验证过,那么就会验证<br>c. 如果指定了这个key,且context被验证过了,那就不会再验证这个context.

### 0x05 获取搜索结果可用的属性

Keys | Value | Comment
:---------:|----------|---------
**Item Result Keys**||
kSecReturnData|CFBooleanRef|是否返回item的data,返回类型为`CFDataRef`<br>对于keys/password的item,数据是被加密的,**可能**会要求用户输入密钥来访问,如果不需要,返回给用户前就数据会被解密<br>对于key items来说,返回的数据与`SecKeyCopyExternalRepresentation`返回值格式相同
kSecReturnAttributes|CFBooleanRef|返回一个`CFDictionaryRef`(**未加密**的属性字典),
kSecReturnRef|CFBooleanRef|根据item的class来返回references:`SecKeychainItemRef`, `SecKeyRef`, `SecCertificateRef`, `SecIdentityRef`, or `CFDataRef`
kSecReturnPersistentRef|CFBooleanRef|item返回的persistent reference是一个`CFDataRef`,它可以储存在磁盘上/在进程中传递<br>转换成普通reference的方法,使用SecItemCopyMatching,search attributes中的`SecMatchItemList`传persistent reference数组,return type设置kSecReturnRef为true
**Item Value Type Keys**||
kSecValueData|CFDataRef|keys/password item,加密
kSecValueRef|struct|`SecKeychainItemRef`, `SecKeyRef`, `SecCertificateRef`, `SecIdentityRef`, or `CFDataRef`
kSecValuePersistentRef|CFDataRef|

### 0x06 ACL 控制 Keychain item 的访问

默认情况下,你可以在设备解锁的情况,访问到所有的钥匙串;
如果需要更高的安全级别，可以使用 `kSecAttrAccessible` 自定义设置安全访问属性

![SamuelChan/20181029203052.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181029203052.png)

```objc
//函数原型:
//a.可以使用在"SecItemAdd", "SecItemUpdate", or "SecKeyGeneratePair"的入参中
//b.ACL过程会阻塞主线程,可以将操作放在后台,或者 kSecUseAuthenticationContext搭配使用 kSecUseAuthenticationUI

//allocator : 一般传NULL/kCFAllocatorDefault,使用默认的allcator
//protection : accessbible的一种,如果kSecAttrAccessControl属性,kSecAttrAccessible就不要再设置
//flags : 枚举值
    //a. kSecAccessControlDevicePasscode
    //b. kSecAccessControlBiometryAny : TouchId或者FaceId必须可用,新增的也可以使用
    //c. kSecAccessControlBiometryCurrentSet : Item只对当前的FaceID/TouchId可见,新增/移除,该Item都变成无效
    //d. kSecAccessControlUserPresence : passcode/TouchId/FaceId,
    //e. kSecAccessControlApplicationPassword : 额外的item密码，新增/更新时让用户自己设置一个访问密码，这样只有知道密码才能访问。
    //f. kSecAccessControlPrivateKeyUsage : 苹果文档标明这个属性 必须必须必须 是跟Secure Enclave一起使用的,否则签名/验证/加密/解密会失败
//error: error
//返回值: 新创建的ACL obj,不需要使用时需要 CFRelase释放对象
SecAccessControlRef SecAccessControlCreateWithFlags(CFAllocatorRef allocator, CFTypeRef protection, SecAccessControlCreateFlags flags, CFErrorRef  _Nullable *error);

//例如下面的代码
CFErrorRef error = NULL;
SecAccessControlRef aclRef = SecAccessControlCreateWithFlags(NULL, kSecAttrAccessibleWhenUnlocked, kSecAccessControlDevicePasscode, &error);
```

## CFFoudation 内存管理

> 操作 Security.framework 的 api 会涉及到 CFFoundation 与 NSFoundation 对象互相转换的内存管理问题（ARC 不会处理 CFFoundation 对象的内存管理），以下问题只考虑 ARC 情况下

- __bridge: 只做类型转换，不修改相关对象的引用计数，原来的 Core Foundation 对象在不用时，需要调用 CFRelease 方法。
  - 从 NS 转 CF，ARC管理内存
  - 从 CF 转 NS，需要开发者手动释放，不归ARC管
  - ARC : __bridge __strong == __bridge_retained

- __bridge_retained：将 NSFoundation 对象转换为 Core Foundation 对象，Core Foundation 对象的引用计数加 1，Core Foundation 对象需要调用 CFRelease 方法手动释放。

- __bridge_transfer：将 Core Foundation 对象转换为 NSFoundation 对象，类型转换后，将该对象的引用计数交给 ARC 管理

举个🌰： 使用 `Instruments` 会发现下面的代码存在内存泄漏，问题出在哪里?

```objc
//测试钥匙串创建
-(IBAction)testCreateKeychain {

    CFErrorRef error = NULL;
    SecAccessControlRef aclRef = SecAccessControlCreateWithFlags(NULL, kSecAttrAccessibleWhenUnlocked, kSecAccessControlDevicePasscode, &error);
    //创建一条类型为kSecClassGenericPassword，需要输入passcode验证的item
    NSDictionary *query = @{
                            (__bridge __strong id)kSecClass : (__bridge id)kSecClassGenericPassword,
                            (__bridge __strong id)kSecAttrAccount : @"Samuel",
                            (__bridge __strong id)kSecAttrService : @"samuel.testKeychain.com",
                            (__bridge __strong id)kSecValueData : [@"passwordOfSamuel" dataUsingEncoding:NSUTF8StringEncoding],
                            (__bridge __strong id)kSecAttrAccessControl : (__bridge id)aclRef
                            };
    OSStatus sanityCheck = SecItemAdd((__bridge CFDictionaryRef)(query), NULL);

    self.textView.text = [self.textView.text stringByAppendingString:[self errormMessageWithOSStatus:sanityCheck]];
}
```

原因出在 `(__bridge __strong id)kSecAttrAccessControl : (__bridge id)aclRef`，这里的 aclRef 对象的 ownership 并没有转移，上述代码忽略了 aclRef 的内存管理，所以发生了内存泄漏

修改的办法有两种：

1. 将 ownership 转移，由 ARC 进行内存管理 ：`(__bridge __strong id)kSecAttrAccessControl : (__bridge_transfer id)aclRef`
2. 手动释放 aclRef 对象 : `CFRelease(aclRef)`



## 其他

- iCloud Keychain
- Keychain Backup


## 参考资料

[Confusion about Keychain Data Protection in White-paper statement](https://forums.developer.apple.com/thread/111952)

[Keychain Services](https://developer.apple.com/documentation/security/keychain_services?language=objc)

[Objective-C 和 Core Foundation 对象相互转换的内存管理总结](https://blog.csdn.net/yiyaaixuexi/article/details/8553659)

[理解 iOS 的内存管理](https://blog.devtang.com/2016/07/30/ios-memory-management/)

[How iOS Security Really Works WWDC 2016 Session 705](https://devstreaming-cdn.apple.com/videos/wwdc/2016/705s57mrvm8so193i8c/705/705_hd_how_ios_security_really_works.mp4)

[What's New in Security WWDC 2016 Session 706](https://devstreaming-cdn.apple.com/videos/wwdc/2016/706sgjvzkvg6rrg9icw/706/706_hd_whats_new_in_security.mp4)

[Security and Your Apps WWDC 2015 Session 706](https://devstreaming-cdn.apple.com/videos/wwdc/2015/706nu20qkag/706/706_hd_security_and_your_apps.mp4)