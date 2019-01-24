**目录**   

- [edgesForExtendedLayout;translucent;extendedLayoutIncludesOpaqueBars](#edgesforextendedlayouttranslucentextendedlayoutincludesopaquebars)
- [topLayoutGuide bottomLayoutGuide与布局位置](#toplayoutguide-bottomlayoutguide%E4%B8%8E%E5%B8%83%E5%B1%80%E4%BD%8D%E7%BD%AE)
- [layoutMargin,layoutMarginGuide](#layoutmarginlayoutmarginguide)
- [安全区相关safeLayoutGuide,safeAreaInsets:](#%E5%AE%89%E5%85%A8%E5%8C%BA%E7%9B%B8%E5%85%B3safelayoutguidesafeareainsets)
- [总结](#%E6%80%BB%E7%BB%93)
- [参考资料](#%E5%8F%82%E8%80%83%E8%B5%84%E6%96%99)

> 公司项目使用的是manual layout(frame) - - ,最近适配iPhone X,可真是被几个概念搞蒙圈了,查了很多资料,算是弄明白了,特地记录总结一下

### edgesForExtendedLayout;translucent;extendedLayoutIncludesOpaqueBars
---
决定的是布局(0,0)的位置

以下概念一般只有在autoLayout才用的上,frame布局一般是用不上的

**(1)edgesForExtendedLayout + translucent :**
edgesForExtendedLayout默认值为UIRectEdgeAll,让rootView从(0,0)开始布局,即view 的内容会被导航栏遮挡住
translucent(半透明)默认值为YES,设置为YES让rootView从(0,0)开始布局;设置为NO会使rootView从导航栏下面开始布局
关系:translucent = NO,edgesForExtendedLayout无效

**(2)extendedLayoutIncludesOpaqueBars + translucent**
关系:translucent = NO,extendedLayoutIncludesOpaqueBars可以修改rootView的布局位置

**(3)automaticallyAdjustsScrollViewInsets**
automaticallyAdjustsScrollViewInsets = YES(default),全屏模式下会自动修改第一个添加到 rootView 的 scrollview 的 contentInset 为(64,0,0,0)

automaticallyAdjustsScrollViewInsets与Top/Buttom Layout Guide在某种程度上，是冲突的:如果vc的第一个子控件是scrollView,并且topLayoutGuide是nav下面,这种情况下就会出现scrollView顶部空白了64pt的情况

`弃用automaticallyAdjustsScrollViewInsets出现的问题`
当在低版本的automaticallyAdjustsScrollViewInsets = NO,并且设置了contentInset来偏移tableView的内容.在iOS11上面就会出现向下偏移64pt的想象,因为默认系统会根据scrollView的contentInsetAdjustmentBehavior属性(UIScrollViewContentInsetAdjustmentAutomatic.)计算出安全区域的高度,然后与contentInset相加

### topLayoutGuide bottomLayoutGuide与布局位置
---
>- manual layout:一般用不上
>- xib/sb       : 如果适配iOS8的话,可以不管safeLayoutGuide,topLayoutGuide bottomLayoutGuide依然可以使用
                 如果适配的是iOS9以前的话,大胆勾选 `safe area layout guide` :Apple told us in [WWDC 2017 Session 412](https://developer.apple.com/wwdc17/412) that Storyboards using safe areas are backwards deployable. This means you can switch to using the safe area layout guide in Interface Builder even if you still target iOS 10 and older.
>- 纯代码       : if(iOS11 available){safeLayoutGuide}else{bottomLayoutGuide,topLayoutGuide}


以topLayoutGuide为例
> Indicates the highest vertical extent for your onscreen content, for use with Auto Layout constraints.

topLayoutGuide代表着被导航栏/状态栏遮挡的内容区域,一般用于autoLayout
![SamuelChan/20171030103536.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20171030103536.png?imageMogr2/auto-orient/thumbnail/600x/blur/1x0/quality/75|imageslim)

Navigation从parent请求insets
![SamuelChan/20171030103610.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20171030103610.png)
然后我们的VC再从Navigation处获得：
![SamuelChan/20171030103639.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20171030103639.png)

注意点:
- 在viewDidLayoutSubviews中访问该值
- 该属性由ParentVc定义
- 布局原点由edgesForExtendedLayout;translucent;extendedLayoutIncludesOpaqueBars决定
- 如果navbar/tabBar/toolBar是不透明并且可视,那么topLayoutGuide/bottomLayoutGuide都为0
  : navBar如果透明并且可视(布局原点是navBar底部),topLayoutGuide的高度就从navBar底部到vc顶部,高度就为0;
  否则,如果如果navbar是透明的(布局原点是屏幕最左上角),topLayoutGuide的高度就是nav底部到vc顶部

```objc
//tabVC → navVc → vc
//布局原点从屏幕左上角开始
2017-10-30 10:28:05.173014+0800 self.topLayoutGuide.length = 64.000000
2017-10-30 10:28:05.173121+0800 self.bottomLayoutGuide.length = 49.000000
2017-10-30 10:28:05.173570+0800 self.navigationController.topLayoutGuide.length = 20.000000
2017-10-30 11:03:20.913381+0800 self.navigationController.bottomLayoutGuide.length = 49.000000
2017-10-30 11:03:20.917491+0800 self.tabBarController.topLayoutGuide.length = 20.000000
2017-10-30 11:03:20.918560+0800 self.tabBarController.bottomLayoutGuide.length = 0.000000

//布局原点从nav下面开始
2017-10-30 11:06:11.156512+0800 self.topLayoutGuide.length = 0.000000
2017-10-30 11:06:11.156613+0800 self.bottomLayoutGuide.length = 49.000000
2017-10-30 11:06:11.157040+0800 self.navigationController.topLayoutGuide.length = 20.000000
2017-10-30 11:06:11.157362+0800 self.navigationController.bottomLayoutGuide.length = 49.000000
2017-10-30 11:06:11.158026+0800 self.tabBarController.topLayoutGuide.length = 20.000000
2017-10-30 11:06:11.158326+0800 tableView safeArea test[9914:3694383] self.tabBarController.bottomLayoutGuide.length = 0.000000
```

参考资料
[UITableView  Layout 上的是是非非](http://www.bijishequ.com/detail/258333?p=)


### layoutMargin,layoutMarginGuide
---
基于约束的auto layout, 使我们搭建能够动态响应内部和外部变化的用户界面. Auto Layout为每一个view都定义了margin. margin指的是控件显示内容部分的边缘和控件边缘的距离.
可以用layoutMargins或者layoutMarginsGuide属性获得view的margin,margin是视图内部的一部分.layoutMargins允许获取或者设置UIEdgeInsets结构的margin. layoutMarginsGuide则获取到只读的UILayoutGuide对象.
![SamuelChan/20171030114616.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20171030114616.png)

iOS11新增:
1.directionalLayoutMargins
directionalLayoutMargins.tralling = layoutMarginsGuide.left
directionalLayoutMargins.leading  = layoutMarginsGuide.right
```
typedef struct NSDirectionalEdgeInsets {  
    CGFloat top, leading, bottom, trailing;
} NSDirectionalEdgeInsets API_AVAILABLE(ios(11.0),tvos(11.0),watchos(4.0));
```

2.自定义view的margin
viewController.viewRespectsSystemMinimumLayoutMargins = NO.
可修改view的margin为任意值


### 安全区相关safeLayoutGuide,safeAreaInsets:
---
**(1)安全区域的概念:系统自动调整tableView内容偏移量，是根据安全区域来调整的。安全区域是iOS 11新提出的，**

![SamuelChan/20171024154934.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20171024154934.png)

安全区域帮助我们将view放置在整个屏幕的可视的部分。即使把navigationbar设置为透明的，系统也认为安全区域是从navigationbar的bottom开始，保证不被系统的状态栏、或导航栏覆盖。可以使用additionalSafeAreaInsets去扩展安全区域使它包括自定义的content在界面上。每个view都可以改变安全区域嵌入的大小，Controller也可以。

safeAreaInsets属性反映了一个view距离该view的安全区域的边距。对于一个Controller的根视图而言，SafeAreaInsets值包括了被statusbar和其他可视的bars覆盖的区域和其他通过additionalSafeAreaInsets自定义的insets值。view层次中的其它view，SafeAreaInsets值反映了该view被覆盖的部分。如果一个view全部在它父视图的安全区域内，则SafeAreaInsets值为(0,0,0,0)。

竖屏的安全区:直向时的 Safe Area 可延伸至屏幕左右兩侧，上部留 44pt给Status Bar；Layout Margins 通常左右再内缩 15pt,底部留34pt给Home Indicator
`view.safeAreaInsets = {88, 0, 83, 0}`

横屏的安全区:橫向时的 Safe Area 左右两侧都内缩44pt；Layout Margins 通常左右再內缩15pt。
`view.safeAreaInsets = {32, 44, 53, 44}`

![SamuelChan/20171030145145.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20171030145145.png)

![SamuelChan/20171030145349.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20171030145349.png)

![SamuelChan/20171031110215.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20171031110215.png)

**(2)viewSafeAreaInsetsDidChange的调用顺序**
lifecycle:

viewDidLoad

viewWillAppear

viewSafeAreaInsetsDidChange

SafeAreaInsets
  - top : 20.0+44.0
  - left : 0.0
  - bottom : 34.0 + 49.0
  - right : 0.0

viewWillLayoutSubviews

viewDidAppear

只有在调用viewSafeAreaInsetsDidChange及以后的方法才能获得view和Controller的SafeAreaInsets。所以在viewDidLoad中根据Safe Area设置界面会有问题。


**(3)adjustContentInset属性的计算方式**
首先看scrollView在iOS11新增的两个属性：adjustContentInset 和 contentInsetAdjustmentBehavior。
```objc
  /* Configure the behavior of adjustedContentInset.Default is UIScrollViewContentInsetAdjustmentAutomatic.*/
  @property(nonatomic) UIScrollViewContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior
  
  contentInsetAdjustmentBehavior → SafeAreaInsets → adjustContentInset
```
- **`UIScrollViewContentInsetAdjustmentAutomatic`**：如果scrollview在一个automaticallyAdjustsScrollViewContentInset = YES的controller上，并且这个Controller包含在一个navigation controller中，这种情况下会设置在top & bottom上 adjustedContentInset = safeAreaInset + contentInset不管是否滚动。其他情况下与UIScrollViewContentInsetAdjustmentScrollableAxes相同

- **`UIScrollViewContentInsetAdjustmentScrollableAxes`**: 在可滚动方向上adjustedContentInset = safeAreaInset + contentInset，在不可滚动方向上adjustedContentInset = contentInset；依赖于scrollEnabled和alwaysBounceHorizontal / vertical = YES，scrollEnabled默认为yes，所以大多数情况下，计算方式还是adjustedContentInset = safeAreaInset + contentInset

- **`UIScrollViewContentInsetAdjustmentNever`**: adjustedContentInset = contentInset

- **`UIScrollViewContentInsetAdjustmentAlways`**: adjustedContentInset = safeAreaInset + contentInset

当contentInsetAdjustmentBehavior设置为`UIScrollViewContentInsetAdjustmentNever`的时候，adjustContentInset值不受SafeAreaInset值的影响。

```objc
tableview.contentInset: {64, 0, 60, 0}

tableview.safeAreaInsets: {20, 0, 0, 0}

tableview.adjustedContentInset: {84, 0, 60, 0}
```

**(4)additionalSafeAreaInsets**
红蓝safeAreaInsets的safeAreaInsets:{44,0,0,0};
![SamuelChan/20171027184003.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20171027184003.png?imageMogr2/thumbnail/!65p)
在一个控制器中，安全区域并不是固定不变的，可以通过 ViewController 的 additionalSafeAreaInsets 方法来修改页面的安全区域，如果此时将安全区域上延 11 个点。
那么它们的 safeAreaInsets 都会变为 {33, 0, 0, 0}。


**(5)安全区导致的iOS11部分UI问题解决:**
- 如果之前是使用contentInset来设置内容偏置的话:那么设置contentInset = (0,0,0,0),让系统自己计算
- 如果不需要系统为你设置边缘距离，可以做以下设置：
```objc
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
```
- iOS11之后viewForHeaderInSection和heightForHeaderInSection要同时实现

- 关闭UITableView的self-sizing
    [UITableView appearance].estimatedRowHeight = 0;
    [UITableView appearance].estimatedSectionHeaderHeight = 0;
    [UITableView appearance].estimatedSectionFooterHeight = 0;



### 总结
1. 宏定义:之前只要使用了这些宏定义计算了计算frame一般都没有什么工作量
```objc
/** iPhoneX机型判断
#define iPhoneX ((CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375))) ? YES : NO)
/** Home指示器 */
#define kHomeIndicator 34
/** 系统tabbar高度 */
#define kAppTabBarHeight (iPhoneX ? (49+kHomeIndicator) : 49)
/** 状态栏高度 */
#define kAppStatusBarHeight (iPhoneX ? 44 : 20)
```

2. 官方布局建议:元素一般都需要在安全区内,除了长列表除外,如下图
![SamuelChan/20171030162053.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20171030162053.png?imageMogr2/auto-orient/thumbnail/500x/blur/1x0/quality/75|imageslim
)

3. HomeIndicator自动隐藏的适配
```objc
//home Indicator是否隐藏或者显示
- (BOOL)prefersHomeIndicatorAutoHidden
{
    return _isYesOrNo;
}

//还需要在_isTrueOrFalse更改时手动调用
_isTrueOrFalse = YES;
if (@available(iOS 11.0, *)) {
  [self setNeedsUpdateOfHomeIndicatorAutoHidden];
}
```

### 参考资料
---
[iOS 11 安全区域适配总结](https://mp.weixin.qq.com/s/W1_0VrchCO50owhJNmJnuQ)

[iOS Safe Area](https://medium.com/rosberryapps/ios-safe-area-ca10e919526f)

[Safe Area Layout Guide](https://useyourloaf.com/blog/safe-area-layout-guide/)

[Human Interface Guidelines iPhoneX](https://developer.apple.com/ios/human-interface-guidelines/overview/iphone-x/)