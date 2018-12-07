# 1Password安全工作原理

> 1Password 是一款密码管理工具，支持Windows, Mac, iOS, Android, Linux, Safari Extension, Chrome Extension, Command Line。 在 Mac 上, 你只需要在输入密码时使用 `Command + \` 就可以完成密码填充，通过 1Password paper 我们可以了解到它的安全机制（尽管有白皮书很多内容都还没有公开）

## 白皮书

> 白皮书版本: [git] • Branch: master @ 288a94d • Release: v0.2.7 (2018-09-10)

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181206140717.png)

1Password 的核心 overview 如图所示，资料来源 [David Schuetz](https://darthnull.org/security/2018/11/09/1pass-misc/)， 博客上面有非常详细关于1Password的系列文章. 我们可以将图中划分为以下三个部分:

- 2SKD
- Organizing and Sharing Passwords
- Multi-Account Management

### 0x00 2SKD

1Password 的安全机制依赖于 `2SKD`(two-secret key derivation)，"two-secret key"指的是 **Master password** 和 **Secret Key**，将它们进行运算生成 `MUK`(用于加密密钥)和 `SRP-x`(用于验证c-s双方身份和密钥交换)的过程被称为 `2SKD`

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181204192535.png)

#### Master Password

即解锁 1Password 的主密码，使用1Password的用户只需要记住这个密码就可以管理它的所有密码.

1Password不会在本地储存 Master Password，**只会**运行时保存在内存中

#### Secret Key

Secret Key(也叫Account Key)分为三部分:

- `Version`固定为:`A3`
- `AccountID`: 随机但是不私密
- `Secret`部分为26个随机并且私密的，这部分的熵为128位(31^26 = 2^128)

Secret Key在本地生成，保存在本地，**不会**上传到服务器

Version| Account ID | Secret
---------|----------|---------
 A3 | -ASWWYB | -798JRY-LJVD4-23DC2-86TVM-H43EB

#### MUK 与 SRP-x

![MUK 与 SRP-x](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181204195342.png)

MUK 和 SRP-x的生成过程类似，差别只在于 Salt 和 Version，详细的过程步骤如下图

```json
 Key Derivation
1∶ 𝑝 ← Master Password from user
2∶ (k𝐴，𝑒，𝐼，𝑠) ← Secret Key， email address， ID， salt from local storage
3∶ 𝑝 ← trim(𝑝)
4∶ 𝑝 ← normalize(𝑝)
5∶ 𝑠 ← HKDF(𝑠， version， 𝑒， 32) //16为的Salt → 32位
6∶ k𝑚 ← PBKDF2(𝑝， 𝑠， 100000)
7∶ k𝐴 ← HKDF(k𝐴 ， version， 𝐼 ， ‖k𝑚 ‖) //version: MUK:PBES2g-HS256 SRP-x: SRPg-4096
8∶ k𝑚←k𝑚⊕k𝐴
9∶ k𝑚 ← JWKify(k𝑚)
```

#### 账户初始化

- 注册: 客户端生成多个密钥，将一些信息上传到Server，1Password 没有能力获取你的明文私钥，都是加密的。
    ```json
    1. Generate SecretKey𝜉 ⤴️
    2. Compute MUK
        (a) Generate encryption key salt𝜉 ⤴️
        (b) Derive MUK from encryption salt，Master
        Password and Secret Key as described in Key derivation. 🔑
    3. Create encrypted account keyset
        (a) Generate private key𝜉 🔑
        (b) Compute publickey(from privatekey)🔑 ⤴️
        (c) Encrypt private part with MUK🔐 ⤴️
        (d) Generate keyset UUID𝜉 ⤴️
        (e) Include keyset format ⤴️
    4. User information
        (a) Given name ⤴️
        (b) Family name ⤴️
        (c) Image avatar ⤴️
        (d) Email ⤴️
    5. Device information ⤴️
        (a) Generate device UUID𝜉 ⤴️
        (b) Operating system(if available) ⤴️
        (c) User agent(if applicable) ⤴️
        (d) Hostname(ifavailable) ⤴️
    6. Construct SRP verifier
        (a) Generate authentication salt𝜉 ⤴️
        (b) Derive SRP-𝑥 from Master Password，SecretKey，and authentication salt 🔑
        (c) Compute SRP verifier from SRP-𝑥.🔑 ⤴️
    7. Send to the server everything listed as‘⤴️’.
    ```

- 如果已经注册，新增 setUp 设备
    ```json
    1. 客户端email address 和 device UUID，服务器会将注册过程上传的信息(2SKD的参数)下发
    {
      "accountKeyFormat" : "A3"，
      "accountKeyUuid" : "GWM4R8"，
      "sessionID" : "TRYYDRPO2FDWRITHY7BETQZPN4"， "status" : "ok"，
      "userAuth" : {
        "alg" : "PBES2g-HS256"， "iterations" : 100000，
        "method" : "SRPg-4096"，
        "salt" : "WSwigQtQpxqYAri592W1lg"
        }
    }

    2. 客户端根据这些参数，结合新增设备输入的 SecretKey，Master Password等信息来生成 SRP-x 来进行与服务器的校验
    ```

- 验证:1Password 使用 SRP 来密钥交换和身份验证

    在 1Password 中的客户端与服务器之间的通信，你的密码 Master Password 永远不会(明文/被加密)被传输。_那么1Password使用了什么机制来保障身份校验和通信的安全呢?_

    正是我们前面提到的 SRP 的方式，它是在 `Diffie-Hellman key exchange` 基础上进行了修改，传统的 `Diffie-Hellman key exchange` 只能保证能在不暴露任何密钥的情况，完成通信密钥的协商，但是他无法校验通信双方的身份。1Password 使用了 SRP 方式，既能保证通信密钥的协商安全性，又能验证通信双方的身份

    具体的做法如下:

    1. initial setUp: `x` 是我们前面提到32位的`SRP-x`，将它转换被BigNum，计算 `v = g^x`，发送到 Server 中

    2. Normal sign in: 如下图的一系列 math 计算，我们可以证明双方能得到一个相同的密钥，完成身份的同时，这个 K1/K2 还作为 sessionKey 来加密后续的 C-S 通信

        - x: SRP-x， v= g^x

        - g，k: 公开的

        - a: Client的随机数，不公开 b: Server的随机数，不公开

        Client | Server |
        ---------|----------|
         A = ga ⤴️ | B=kv+gb ⤴️ |
         u = SHA256(A\|B) | u = SHA256(A\|B) |
        (B - kgx)(a + ux) | (Avu)b |
        (kv + gb - kgx)(a + ux) | (gavu)b |
        (kgx + gb - kgx)(a+ux) | (ga(gx)u)b |
        (gb)(a+ux) | (g(a+ux))b |
        K1 = hash((gb)(a+ux)) | K2 = hash(g(a+ux))b |

### 0x01 Organizing and Sharing Passwords

> 这部分是关于 1Password 是利用 MUK 和 SPR-x 如何管理和分享密码的

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181204201534.png)

每个账户可以有多个 Keyset， 其中第一个 Keyset 称为 Primary Keyset，每个 Keyset 可以有多个 Valut (保险库).

创建账户时会生成 `RSA公私钥对` 和 `AES symmetric Key`( _如果是Primary Keyset的话，我们将这个 AES key 叫做 Master key_ )

- 创建新的Valut时
    - 会同时生成一个256bit的 `Vault Key`，存放在`vault access table`中， 对 item 进行 AES-GCM 加密
    - item 分为 overview 和 detail 两部分，分别存放在`vaults table`和`items table`中， overview 用来查询，detail 保存真正的密码，这两部分分别使用`Vault Key`加密
- `MUK` 加密 `AES MP key`
- Primary Keyset 的 `AES MP key` 加密 `RSA-Private`
- `RSA-Public`加密 Keyset2，Keyset3 的 `AES symmetric Key`
- `RSA-Public` 加密 `Vault Key`

一个Keyset格式(Keyset的格式是 JWK,RFC7517)

```
{
    "encPriKey" : { //RSA privateKey
    "kid": "c4pxet7agzqqhqg9yvxc2hkg8g",
    "enc": "A256GCM"，
    "cty": "b5+jwk+json"，
    "iv": "dBGJAy3uD4hJkf0K"，
    "data": "YNz19jMUffFP_glxM5Z ..."
  }，
  "encSymKey": {  //AES symmetricKey
    "kid": "mp"，
    "enc": "A256GCM"，
    "cty": "b5+jwk+json"，
    "iv": "X3uQ83tlrdNIT_MG"，
    "data": "gd9fzh8lqq5BYdGZpypXvMzIfkS ..."，//使用MUK和iv，data进行AES解密

    //用来生成MUK的参数
    "alg": "PBES2g-HS256"，
    "p2c": 100000，
    "p2s": "5UMfnZ23QaNVpyeKEusdwg"
  }，
  "encryptedBy" : "mp"， 
  "pubKey": {       //RSA-publicKey
     "alg": "RSA-OAEP-256"， 
     "e": "AQAB"， 
     "key_ops": ["encrypt"]， 
     "kty": "RSA"，
     "n": "nXk65CscbXVuSq8I43RmGWr9eI391z ..."，
     "kid": "c4pxet7adzqqvqg9ybxc2hkg8g"
  }，
}，
  "uuid" : "c4pxet7a..."，
}
```

#### Share vault

`Share`，`Revoke`，`Recovering from lost password` 都是账户类型为 Team/Family 才有的功能

用户A 可以将一个 vault 共享给 用户B 的过程:

- A 创建一个vault，vault 中的 item 被 vault key加密
- A 将 vault 共享给 B: 使用 B 的 publickey 来加密
- 1Password 通知 B 有共享的库: B 将 vaultKey(🔐) 和 vault Item(🔐) 下载下来，这样只有 B 可以用自己的 privateKey 来解密使用这个 vault

#### Revoke

Team/Family 的管理员可以 revoke 某个用户对共享 vault 的访问权限， 1Password 会做两件事情:

- 新增的 vault item 将不会再发送给 revoke 掉的用户
- 1Password 会通知客户端**删除**本地储存的vault item
- 如果用户一直没有联网，这部分vault item不会被删除，可以参考论坛上面的回答: [What happens if a users access is revoked but offline access to a vault is active?](https://discussions.agilebits.com/discussion/comment/456723#Comment_456723)

#### Recovering from lost password

Recovery Group 会生成一个 keyset(`privateKeyR`/`publicKeyR`)， 每一个 Recovery Group 的成员都会拥有 `privateKeyR`，每当一个新的 vault 生成，vaultKey 会被 `publicKeyR` 加密，vaultKey(🔐) 和 vaultItem(🔐) 都会被上传到 1Password 中

恢复的过程就是 **Recovery Group 的成员利用手中的 privateKeyR 解锁获得 vaultKey，然后用新的 publicKey 重新加密的过程**

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181205180516.png)

1. Bob: Recovery Group的一员；  S: 1Password server；  Carol: 忘记密码的家伙
2. Bob 使用自己的公钥 `pk𝐵` 来加密 Recovery Group 的私钥 `sk𝑅`
3. Carol 创建一个新的 vault ，并且生成 vault Key --- `k𝑣`
4. 使用 `k𝑣` 来加密 vault 中的 item，即 `𝑑𝑣𝑒`
5. 使用 Recovery Group 的公钥加密 `pk𝑅` 来加密 `k𝑣`，生成 `𝑅𝑣`，并与 `𝑑𝑣𝑒` 一起上传到 1Password Server中
6. 当 Carol 忘记自己的密码，无法登录，她请求 Recovery 账户，Bob 需要同意该请求
7. Carol 生成一对新的公私钥对(`pk𝐶`，`sk𝐶`)，并将`pk𝐶`上传到服务器
8. 服务器将 `pk𝐶` 和 `𝑅𝑣` 一起回传给 Bob
9. Bob使用自己的私钥 解锁 `sk𝑅`，然后再用 `sk𝑅` 来解锁出 `k𝑣`， 使用最新的`pk𝐶`来加密 `k𝑣` 传给 Carol
10. Carol可以使用自己的私钥 `sk𝐶` 来解密出得到 `k𝑣`，恢复成功

### 0x03 多账号管理

> 多账号管理 Windows 和 Mac 的做法是不一样的，这里只关注 **Mac**， Windows 的多账号管理可以参考[1Password - Unlocking Windows Clients
](https://darthnull.org/security/2018/11/09/1pass-emk/)

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181205190404.png)

一个终端可以有多个账号，我们可以只使用一个 Master password 就可以解锁使用多个账号(主账户解锁其他的账户)。如果主账户被删除了，那么下一个账户就变成主账户

在Mac上面，主账户进行 2SKD 生成 MUK，MUK 解锁主账户的 Primary Keyset，得到 **Master Password**，MP 会用于解锁`次账户`的 accout data(包括了 MUK和 SRP-x)


### 动手尝试

Client | Vaults | Secret Key| Master Password|
---------|----------|---------|----------|
 macOS | **~/Library/Group Containers/2BUA8C4S2C.com.agilebits\/Library/Application Support/1Password/Data** | **com.agilebits.onepassword.b5Credentials** |User’s memory
 Windows | x | Encrypted in vault | Encrypted in vault
 Web Browser | (n/a – fetched on demand) | Browser local storage (obfuscated) |User’s memory

在 `~/Library/Group Containers/2BUA8C4S2C.com.agilebits\/Library/Application Support/1Password/Data` 目录下有文件：

```shell
B5.sqlite  B5.sqlite-wal  OnePassword.sqlite-shm
B5.sqlite-shm  OnePassword.sqlite  OnePassword.sqlite-wal
```

B5.sqlite里面有这几个表

```shell
account_billing
accounts //账户表
categories
config
export_keys
item_tags
item_urls
item_usage
items  //vault items表
keysets //keyset表
tags
user_overview
user_personal_keys
vault_access  //存放vaultKey表
vaults //存放vault信息的表
```

我们可以通过这几个表来验证我们上面说的一大篇幅的原理：利用 David Schuetz 利用的[工具](https://github.com/dschuetz/1password), 它提供 AES, RSA, 2SKD 的 python 脚本，你可以选择通过这个仓库提供的 `test vector` 或者 通过 Mac 1Password 储存的自己账户数据库文件（Navicat SQLite可视化工具）来进一步验证 1Password 的工作机制。

- 安装pip: `sudo easy_install pip`
- 安装python依赖
    - pycryptodome ：`pip install pycryptodomex`,文档在[这里](https://pycryptodome.readthedocs.io/en/latest/src/installation.html)
    - pyjwkest: `sudo pip install pyjwkest`

- 从钥匙串复制`com.agilebits.onepassword.b5Credentials`的值
- 2SKD：`python 2sdk.py`
- AES-GCM解密： `python gcm_decrypt.py`
- RSA解密：`python rsa_decrypt.py`

动手解密的过程非常有趣，你可以自己试试，简单画一个示意图：

> 注意点：1Password的Base64编码使用了 url-safe replacing `- and _` with `+ and /`

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20181207162520.png)

下面我们使用 [工具](https://github.com/dschuetz/1password) 中的 `test_data.txt` 中的 `test vector` 来尝试一下（如果你有账号，用真实的数据是最好的）

1. 计算 MUK : 结果为 `6VIFjzKXaHctk44NXr8hOenpgwxWgZebtOlGkPwGK-Y=`

```shell
$ python 2skd.py

Enter the account's Secret Key (A3-xxx....): A3-ASWWYB-798JRY-LJVD4-23DC2-86TVM-H43EB

Enter the master password:update-clown-squid-bedpost

Enter the email address: nobody@example.com

Enter the 'p2s' parameter (salt, base-64 or hex encoded): cA4f6QY7wwUoclj74RMvUg==

Enter the 'p2c' parameter (iterations count): 100000

Enter the 'alg' parameter
  (PBES2g-HS256 for MUK, SRPg-4096 for SRP-x) (note: case sensitive): PBES2g-HS256


** Computing 2SKD

Password             update-clown-squid-bedpost
Email                nobody@example.com
Secret Key           A3-ASWWYB-798JRY-LJVD4-23DC2-86TVM-H43EB
   Version           A3
   AcctID            ASWWYB
   Secret            798JRYLJVD423DC286TVMH43EB
Algorithm            PBES2g-HS256
Iterations (p2c)     100000
Salt (p2s)           cA4f6QY7wwUoclj74RMvUg==

Salt (decoded)       700e 1fe9 063b c305 2872 58fb e113 2f52   

HKDF(ikm=p2s, len=32, salt=email, hash=SHA256, count=1, info=algorithm)

HKDF out: pass salt  ef4b 0bc3 81a6 87cf c6e3 c8bb d94f 6363   
                     62bb ebf5 174f 417f 5d6b 5295 95b8 d533 

PBKDF2(sha256, password, salt=HKDF_salt, iterations=p2c, 32 bytes)

Derived password key ff47 5c0e f6d7 c87b 11b5 84a4 02ab ae84   
                     18f6 850e 8b90 4234 f396 2440 cd49 99d9 

HKDF(ikm=secret, len=32, salt=AcctID, hash=SHA256, count=1, info=version)

HKDF out: secret key 1615 5981 c440 a00c 3c26 0aa9 5c14 8fbd   
                     f11f 0602 dd11 d5af 477f 62d0 314f b23f 

XOR PBKDF2 output and SecretKey HKDF output

Final 2SKD out       e952 058f 3297 6877 2d93 8e0d 5ebf 2139   
                     e9e9 830c 5681 979b b4e9 4690 fc06 2be6 

Base-64 Encoded result: 6VIFjzKXaHctk44NXr8hOenpgwxWgZebtOlGkPwGK-Y=
```

2. 根据 `enc_sym_key` 中的 `iv` 和 `cipherText`，使用 `MUK` 解密 Primary keyset 的 `AES Symmetric Key`(MP)

```shell
$ python gcm_decrypt.py
Enter AES-256 key (hex or base-64 encoded)
 --> 6VIFjzKXaHctk44NXr8hOenpgwxWgZebtOlGkPwGK-Y=
Enter IV (hex or base-64): 2FF8mtGD55z84h9jMtWAyQ==
Enter ciphertext (hex or base-64): 8OjOA2NqUZZGxXD4r-z4QUfxjvuk23_i0DFAcYxx1r84hmsG1KV1G9iKBZd-kFpfzDgciJD3h8d9
1OT9D6F8KVqvdmx_q649mWEhiWwVcmRlKRVzgj-eZunS1XHxwHYDhvNvdzKUpNdAp7EKsQCRpiJJ
3-eTndQBFMdyeCwkxnqMkuGW326P_mjW5yp_qYpGc4HgpY-_3aEhKimKVGJuxL4I5U5LU2ZFVNNh
RIxkjJShtEwtXcTaVwH6


MP: {"key_ops": ["decrypt", "encrypt"], "kty": "oct", "alg": "A256GCM", 
"k": "Sco1rWpdmrLiAeZNtwAlCQsMMqN46AnyGasaMu3EqlQ=", "ext": true, "kid": 
"qn8uimc4l7sofa26yivex24j7q"}
```

3. 根据 `enc_pri_key` 中的 `iv` 和 `cipherText`, 使用 `MP` 解密得到 `Private Key`

```shell
$ python gcm_decrypt.py
Enter AES-256 key (hex or base-64 encoded)
 --> Sco1rWpdmrLiAeZNtwAlCQsMMqN46AnyGasaMu3EqlQ=
Enter IV (hex or base-64): x_pZCisivs-aCINbqS4fLQ==
Enter ciphertext (hex or base-64): V1sG-80rSSwRw7vpHj6dH159IF-35WulxFh_LzJVvu1wb4GXmc7aZzhyMWAx9kLN4t9ZXiY_gdgg
...省略...MARM00-HR4qDygxoypJFATny5SmznhpYbCmT7A9fwKQLWNQbiUAdQfDI-ccM


PrivateKey : {"key_ops": ["decrypt"], "e": "AQAB", "d": 
"XcdvqfcqjGi1h5GloyVJKulotMPOf1iVHd5G0XG6ONnsXFfh3bpXJrfos8MT3rRqNcQmAbmUzDj
ZEDyUeCl_J8GmegxeeZ3X3Iiua6v0ecsjcdz9QAohcEWtza4XQlAcciZQGJqNDKzImXnErUXDHbQ
ebGjEa3Z_b3DjZqfI-QH5DYDMh5W61L7Ky8_8kc54A9EtJupqtKZwYnBtazzLTcl82APkyQ71aN9
kD-iO8qA3lAQGkUykRBa_8TF0tDCGgFfW7ijcGk06NGsYex9ir_n8fYZOP3LXahEMO5_3j4vIixm
ktFpI8IhtdQNvXqYir3JyB3WOmszr5XC4VasAYQ", "alg": "RSA-OAEP", "n": 
"xA6dAIu2_S9Ia_xRkodmvBv9w4pMyjE7FFAiXKTcQJS8d1RLkY82hwghBa6YK7V28_-S0Hfe2_N
ecesRMCpDf03kl1SClJkl8bJpJ0AwZFhvj6JO1JUZAj8o06OpgUCij_Jt8YSiu8bQIXgH5bEEkZ3
oBx1OyozgqCo6JBa7cQVlv2LGV25YnqIbzOTof8YBZMNM0GuzPQQDxJUEB4ktmKekFjtDvHzAUmt
MEgGYpbgXl4AmRAbHlYPpepSBplqXSrJfxVfEgftAJudjQsrMr_uVNX5TYGgFJDqUzkiXBXEUFy2
2GqcIArLLiOtvUwEU843wYpLtSPN-A20YLfSTCw", "q": 
"8Kuuf2mnoNK1skNuxJU38Q6HC6cq9JoHN1U5dYKIcAXd0B1wEqHGcbo8UyviftfdPRy2fomKu1-
c0uWcOzBZmlV4SkQ-_TwxcFPgTVcrhuAESHERZIYJuIr6JENoD7iph_BGOF-ftVGBULT7fFRH47t
0jPkfTolXeC2tLIsQbuU", "p": 
"0It5RDblXwYnJg-xuBrww6bxNr11x8ILCEVojwuAaNFegAqwPHbUw4nekx5mML30HltVgg3i3bi
0ITLdHVqvdy9zUetTsEhsYlk9Zq8ox6nGQ9qEa-Hnu4YCB5Uh5iHMBZyUlmjRUPh1V7NcyafzjgJ
Sin8-Me_DKrHxdalU6y8", "kid": "qn8uimc4l7sofa26yivex24j7q", "kty": "RSA"}
```

4. 利用 `Private Key` 解密数据库表 `vault access` 中的数据 `enc_vault_key`，得到 `vault key`

```shell
$ python rsa_decrypt.py
Enter RSA private key (as json, decrypted from keyset): {"key_ops": ["decrypt"], "e": "AQAB", "d": 
"XcdvqfcqjGi1h5GloyVJKulotMPOf1iVHd5G0XG6ONnsXFfh3bpXJrfos8MT3rRqNcQmAbmUzDj
ZEDyUeCl_J8GmegxeeZ3X3Iiua6v0ecsjcdz9QAohcEWtza4XQlAcciZQGJqNDKzImXnErUXDHbQ
ebGjEa3Z_b3DjZqfI-QH5DYDMh5W61L7Ky8_8kc54A9EtJupqtKZwYnBtazzLTcl82APkyQ71aN9
kD-iO8qA3lAQGkUykRBa_8TF0tDCGgFfW7ijcGk06NGsYex9ir_n8fYZOP3LXahEMO5_3j4vIixm
ktFpI8IhtdQNvXqYir3JyB3WOmszr5XC4VasAYQ", "alg": "RSA-OAEP", "n": 
"xA6dAIu2_S9Ia_xRkodmvBv9w4pMyjE7FFAiXKTcQJS8d1RLkY82hwghBa6YK7V28_-S0Hfe2_N
ecesRMCpDf03kl1SClJkl8bJpJ0AwZFhvj6JO1JUZAj8o06OpgUCij_Jt8YSiu8bQIXgH5bEEkZ3
oBx1OyozgqCo6JBa7cQVlv2LGV25YnqIbzOTof8YBZMNM0GuzPQQDxJUEB4ktmKekFjtDvHzAUmt
MEgGYpbgXl4AmRAbHlYPpepSBplqXSrJfxVfEgftAJudjQsrMr_uVNX5TYGgFJDqUzkiXBXEUFy2
2GqcIArLLiOtvUwEU843wYpLtSPN-A20YLfSTCw", "q": 
"8Kuuf2mnoNK1skNuxJU38Q6HC6cq9JoHN1U5dYKIcAXd0B1wEqHGcbo8UyviftfdPRy2fomKu1-
c0uWcOzBZmlV4SkQ-_TwxcFPgTVcrhuAESHERZIYJuIr6JENoD7iph_BGOF-ftVGBULT7fFRH47t
0jPkfTolXeC2tLIsQbuU", "p": 
"0It5RDblXwYnJg-xuBrww6bxNr11x8ILCEVojwuAaNFegAqwPHbUw4nekx5mML30HltVgg3i3bi
0ITLdHVqvdy9zUetTsEhsYlk9Zq8ox6nGQ9qEa-Hnu4YCB5Uh5iHMBZyUlmjRUPh1V7NcyafzjgJ
Sin8-Me_DKrHxdalU6y8", "kid": "qn8uimc4l7sofa26yivex24j7q", "kty": "RSA"}

Enter ciphertext (base-64 or hex): nVmjCMY9pRdAz19QdWVe4HEpPImxGfRF4RJTkLZChImsct1YQa2IWrMDOlHaW2ywKNFyW1PIGYpm
CZJJZ-WtnDsCbWnCYEtB9EkBdRVbZp5gUEvbv6EMVXQzOc6i9xaC3xG0PcbWGjcfUdP15obnaBqg
TZ6S2kBPL-Kx2oVn6srro-SLcmrVfvulBiOB0iaBm7gRz5ogP4ecGgY8jE-U0dkODN8t3iR7HfQB
ErsakVopWAR34haHfhbli5oenQgNYZhvio3Tc82yPaR6GlLUCHt0bmYOyp_1zzwbQuUy1kBMz4i2
MEZMVa0iue9und7OoXj3B1Zedon9eGy7YrBpcg==

Decrypted data:

vault key : {"key_ops": ["decrypt", "encrypt"], "kty": "oct", "alg": "A256GCM", 
"k": "N5UH1HxXJgtTSrvMHWStrEnuiHiq9Q1Vf064XlCYfgg=", "ext": true, "kid": 
"r07y2eh9nj8vjf20g6a9vpbkv7"}
```

5. 利用 `vault key` 可以解锁 `vault metadata` 和 `item overView & item detail`

```shell
$ python gcm_decrypt.py 
Enter AES-256 key (hex or base-64 encoded)
 --> N5UH1HxXJgtTSrvMHWStrEnuiHiq9Q1Vf064XlCYfgg=
Enter IV (hex or base-64): py0VvhU4S0lsVp3HCWPVBQ==
Enter ciphertext (hex or base-64): k9ilYNPPLH24pdkvUIALswSHSEpAfIn_hvFyd65osu208FKwvUlDw8t5Lf
hUvp8GrkWhxfycqMPlONUe8zl3gv-6wA4PTH-fP56SWaz-MOkrfTucnPSKCWZR
rLAquM6bPxGDAmwKJYVFVqGpSEtK8ypVQ3lIe8hqwtZPILYVG6lh6kv-z7j0


vault metadata : {"desc": "unk-b64-blob", "type": "P", "uuid": 
"ixaw6slq5k7c7d71lwzkh87qy1", "avatar": "", "name": "Test vault: vault1"}

======overview======
$ python gcm_decrypt.py 
Enter AES-256 key (hex or base-64 encoded)
 --> N5UH1HxXJgtTSrvMHWStrEnuiHiq9Q1Vf064XlCYfgg=
Enter IV (hex or base-64): -Hgi93V5ocnDTaZ2J7ZJBg==
Enter ciphertext (hex or base-64): 
7xNaK5OGfG_GgVRMGXTGVZab7ptdj8wBwlsQjUAroUuwngp9LO7sNrY_PW034o1pFseqls8gRgpIi9MjC
5DGhC1ARF50ERZv0Vv-EguFC-Ul913khWlD3cmqs-w=


vault overview : {"ainfo": "account-name", "url": "https://example.com", "title": "My test!"}

======detail======
$ python gcm_decrypt.py
Enter AES-256 key (hex or base-64 encoded)
 --> N5UH1HxXJgtTSrvMHWStrEnuiHiq9Q1Vf064XlCYfgg=
Enter IV (hex or base-64): rj8WUAOeJ1RettqnunyRug==
Enter ciphertext (hex or base-64): wP99G-ktlnIHTGU4NGLiUAzOa8YwuoJPAOaTBZ_R73rqXERyfB3mrebmWuTBbFQGfCVFCYqVGBatl-O7Y
l5McMCFn9DPKaMs8lou08Roxw_tlrv_AtGuFFw4GhmpFytQb78TkYWzBNUaAZLIowEqQNmPZ2nkgJknFA
emtWAWnDWLper7mim91A==

vault detail{"fields": [{"type": "T", "name": "username", "value": "user"}, {"type": "P", "name": "password", "value": "password"}]}
```

## 总结

1Password 使用了 Master Password 和 Secret Key，经过 2SKD 运算，生成 MUK 和 SRP-x，用于加密数据、协商sessionKey、身份校验，1Password 没有保存你的 Master Password 或 Secret Key，如果你的 1Password 是个人账户，且忘记了密码，那么你的密码将无法找回。

白皮书很多地方没有详细描述，但是在官网论坛上的问题都是非常详细的回答，经得起考验。对于现在的 iOS 系统，一般使用 keyChain 来做密码管理就已经足够了，iCloud keyChain 放在贵州不太放心，所以我一般都是关闭 iCloud keyChain。

## 参考资料


[1Password - Full Trip from Unlock to Encryption](https://darthnull.org/security/2018/11/12/1pass-roundtrip/)

[BSidesDE - A deep dive into 1Password Security](https://darthnull.org/security/2018/11/09/1pass-bsidesde/)

[1Password - Wrapping up with a few quick topics](https://darthnull.org/security/2018/11/09/1pass-misc/)

[1Password - Local Vaults](https://darthnull.org/security/2018/11/09/1pass-local-vaults/)

[1Password - Into the Vaults!](https://darthnull.org/security/2018/11/09/1pass-vaults/)

[1Password - Unlocking Windows Clients](https://darthnull.org/security/2018/11/09/1pass-emk/)

[1Password - MUKing about on the Mac](https://darthnull.org/security/2018/11/09/1pass-muking-about/)

[How 1Password Works - Getting under the hood](https://darthnull.org/security/2018/11/09/inside-1password/)

[BSides Delaware 2018 David Schuetz (@DarthNull) How things work: A deep dive into 1Password security](https://www.youtube.com/watch?v=YET7KuLt93M)

[White paper clarifications](https://discussions.agilebits.com/discussion/69566/white-paper-clarifications)

[WhitePaper-errata-in-page40](https://discussions.agilebits.com/discussion/99037/whitepaper-errata-in-page40/p1?new=1)