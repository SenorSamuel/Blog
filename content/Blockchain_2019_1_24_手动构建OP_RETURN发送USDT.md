# 手动构建OP_RETURN发送USDT

<!-- TOC -->

- [手动构建OP_RETURN发送USDT](#手动构建op_return发送usdt)
    - [Quick Link](#quick-link)
        - [区块浏览器](#区块浏览器)
        - [OmniLayer文档](#omnilayer文档)
    - [Omni协议](#omni协议)
        - [USDT交易](#usdt交易)
        - [OP_RETURN](#op_return)
    - [如何使用 Trezor 发送的USDT](#如何使用-trezor-发送的usdt)
    - [其他](#其他)
    - [参考资料](#参考资料)

<!-- /TOC -->

## Quick Link

### 区块浏览器

- BTC 区块浏览器: https://btc1.trezor.io
- BTC 测试网区块浏览器: https://testnet-bitcore2.trezor.io/tx/1b8a4a35031a6571546b626d128689aec7df5a944f062f82eb61b713cd6f28ec
- Omni 区块浏览器: [Omni Explorer](https://www.omniexplorer.info)

### OmniLayer文档

[OmniLayer/spec](https://github.com/OmniLayer/spec#transfer-coins-simple-send)

## Omni协议

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20190123221141.png)

Omni协议(之前叫做 Mastercoin),是建立在比特网络上的一个协议.利用 Omni协议,可以很方便的创建代币,现有比特币网络上发行的代币可以在 [Properties for ecosystem Production](https://www.omniexplorer.info/properties/production) 找到,最知名的就是Tether(USDT).

[Tether（USDT）](https://tether.to/)是 `Tether` 公司推出的基于稳定价值货币美元（USD）的代币Tether USD（下称USDT），用户可以随时使用 USDT 与 USD 进行 1:1 兑换。Tether 公司严格遵守 1：1 的准备金保证，即每发行1个 USDT 代币，其银行账户都会有1美元的资金保障。官方称:用户可以在 Tether 平台进行资金查询(现在查不到)

### USDT交易

BTC网络的一笔USDT交易详情如下: [0347ab8f6291ab38c233576ddc0a4c3156b96d9fa800b07f2962e35c5b40011c](https://btc1.trezor.io/tx/0347ab8f6291ab38c233576ddc0a4c3156b96d9fa800b07f2962e35c5b40011c)

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20190124104451.png)

vins: 这笔交易的  来自 `1JDtcRLZyDQJm9g6xXuuSYEpp7SKagXDc7`的UTXO: 分别是`0.01585606`和`0.00000546`.

vout1: 找零`0.01575606`到`1JDtcRLZyDQJm9g6xXuuSYEpp7SKagXDc7`

vout2: OP_RETURN锁定脚本,这个 vout 是 **Omni** 交易的特征之一,真正要发送的 USDT 数量就是在这个 vout 中体现的,后面详细的介绍

vout3: 往`1NomS9Umy2AJV2xECL89sxwL4RyXmGkyZm`发送 `0.00000546`,一般Omni 交易往目的地址都是发送这么多金额,这个值是BTC网络允许的最低的数量.可以这么理解:USDT是借助了BTC网络来进行交易,所以你只需要支付最少的BTC来保证交易能够创建就可以了(当然也可以超过`0.00000546`,但是没有必要)

### OP_RETURN

以 OP_RETURN 开头的锁定脚本有着以下两种含义:

- 这个 vout 不能被花费
- OP_RETURN后面跟随的是备注信息

在上面的 vout2中: `OP_RETURN 6f6d6e69000000000000001f0000000b0f387b00`代表的意义如下:

- 6f6d6e69 : "omni"的ASCII编码,以为这个备注信息是与 Omni 协议有关系的
- 0000 : Transaction version
- 0000 : Transaction type, 2 Bytes,代表着`Simple Send`
- 0000001f : Currency identifier, 4 bytes. `1f`== `31` == TetherUS
  - BTC主网: 1 and 3 to 2,147,483,647
  - BTC测试网: 2 and 2,147,483,651 to 4,294,967,295
- 0000000b0f387b00 : Amount to transfer. 8Bytes. 数量的十六进制0000000b0f387b00 = 47500000000聪 = 475 USDT

Field | Type | Bytes|Example
---------|----------|---------|---------
 Transaction version | Transaction version | 2| 0
 Transaction type | Transaction type | 2| 0
 Currency identifier | Currency identifier | 4| 1f
 Amount to transfer| Number of Coins| 8|0000000b0f387b00

## 如何使用 Trezor 发送的USDT

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20190124120820.png)

Trezor 是为数不多支持 TetherUS的钱包,强如 Ledger 都还[不支持](https://www.reddit.com/r/ledgerwallet/comments/8kbu03/ledger_support_for_usdt_tether/)

使用 Trezor 来发送 USDT,你可以通过下面两种方式:

- Trezor + Electrum : 这个可以参考[How to send USDT with Electrum](https://jochen-hoenicke.de/crypto/omni/
)

- 官方的Chrome/FireFox extension wallet(下面只介绍这种)

这两种方式核心都是一样的,都是手动构建 OP_RETURN, 然后签名广播

> 下面使用测试网进行说明

步骤一:
新建一个 Legacy 的账号,由于Trezor web wallet不支持指定`send from`,需要保证一个账号只生成一个地址. "账号"的概念指的是HD中第三层,m/44'/1'/1'的意思是:测试网普通地址,第二个账号

步骤二:
> 从`mujE43EZckhHf6i1P2ru9UUg78VTjLwwL3`发送 1666 USDT 到 `msbuQnXJPcqimUi3eiWFE9oPu15Ce7dphm`

- 这里 web前端限制了不能填 `0.00000546`,所以填了`0.00000547`

- 由于 Omni协议中,vout 找零必须找给发送地址,否则,这笔交易将不会被判断为是 Omni交易,只会认为是发送 `0.00000546`的普通BTC交易,所以这里增加一个 vout,将剩下的钱全部转给原 SendFrom 地址`mujE43EZckhHf6i1P2ru9UUg78VTjLwwL3`

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20191011104248.png)

步骤三:
构建OP_RETURN:`OP_RETURN 6f6d6e6900000000800004e70000000000000682`

> 我在BTC Testnet发的币 propertyID 为 2147484903

Field |Example
---------|---------
 Transaction version | 0
 Transaction type | 0
 Currency identifier | 800004e7(hex) == 2147484903
 Amount to transfer|0000000000000682(hex) == 1666

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20190124152818.png)

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20190124152907.png)


最后的交易:[b61dee5fc2f4588bcef39c1e6f12fee9b963c311efc6731ba06e351fcc3dbb75](https://testnet-bitcore1.trezor.io/tx/b61dee5fc2f4588bcef39c1e6f12fee9b963c311efc6731ba06e351fcc3dbb75)

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20190124153403.png)

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20190124153430.png)

## 其他

如果觉得构建 `OP_RETURN` 很麻烦,那么可以使用 Omni 的 maintainer 在 github 发布的一个[工具](http://builder.bitwatch.co/)快速构建OP_RETURN脚本

![](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20190124153736.png)

## 参考资料

[Bitcoin Developer Guide](https://bitcoin.org/en/developer-guide#standard-transactions)

[How to send USDT with Electrum](https://jochen-hoenicke.de/crypto/omni/)

[Create a new Omni Protocol transaction](http://builder.bitwatch.co/)




