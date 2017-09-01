- [禅与Objective-C编程艺术读书笔记](#%E7%A6%85%E4%B8%8Eobjective-c%E7%BC%96%E7%A8%8B%E8%89%BA%E6%9C%AF%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0)
  - [1.条件语句](#1%E6%9D%A1%E4%BB%B6%E8%AF%AD%E5%8F%A5)
  - [2.命名规范](#2%E5%91%BD%E5%90%8D%E8%A7%84%E8%8C%83)
  - [3.类](#3%E7%B1%BB)
  - [4.美化代码](#4%E7%BE%8E%E5%8C%96%E4%BB%A3%E7%A0%81)
  - [5.代码组织](#5%E4%BB%A3%E7%A0%81%E7%BB%84%E7%BB%87)
  - [6.对象之间的通讯](#6%E5%AF%B9%E8%B1%A1%E4%B9%8B%E9%97%B4%E7%9A%84%E9%80%9A%E8%AE%AF)
  - [7.多重代理](#7%E5%A4%9A%E9%87%8D%E4%BB%A3%E7%90%86)

### 禅与Objective-C编程艺术读书笔记

#### 1.条件语句
```Objective-c
1. if (!error) {
	return success;
}

2. 不使用尤达表达式
if ([myValue isEqual:@42]) { ...

3. nil跟BOOL检查: nil解释为NO YES解释为1
if (someObject) { ...
if (![someObject boolValue]) { ...
if (!someObject) { ...
Not Preferred:
if (someObject == YES) { ... // Wrong
if (myRawValue == YES) { ... // Never do this.
if ([someObject boolValue] == NO) { //Wrong

4. Golden Path: 不要嵌套if,减少复杂度
- (void)someMethod {
  if (![someOther boolValue]) {
      return;
  }

  //Do something important
}

5.复杂的条件表达式:如果if的条件判断很复杂,建议先赋值给变量名清晰的BOOL变量
BOOL nameContainsSwift = [sessionName containsString:@"Swift"];  
BOOL isCurrentYear = [sessionDateCompontents year] == 2014;
BOOL isSwiftSession = nameContainsSwift && isCurrentYear;
if (isSwiftSession) {
// Do something very cool
}

6. 三元运算符:优先级从右到左
result = object ? : [self createObject];

7. case: 单行括号不强制,执行直到break
8. 位移枚举
typedef NS_OPTIONS(NSUInteger, UIViewAutoresizing) {    二进制值    十进制
    UIViewAutoresizingNone                 = 0,         0000 0000  0
    UIViewAutoresizingFlexibleLeftMargin   = 1 << 0,    0000 0001  1
    UIViewAutoresizingFlexibleWidth        = 1 << 1,    0000 0010  2
    UIViewAutoresizingFlexibleRightMargin  = 1 << 2,    0000 0100  4
    UIViewAutoresizingFlexibleTopMargin    = 1 << 3,    0000 1000  8
    UIViewAutoresizingFlexibleHeight       = 1 << 4,    0001 0000  16
    UIViewAutoresizingFlexibleBottomMargin = 1 << 5     0010 0000  32
};

//模拟实现
-(void)todo:(UIViewAutoresizing)type{
    if (type==0) {
        NSLog(@"UIViewAutoresizingNone");
        return;
    }
    if (type & UIViewAutoresizingFlexibleLeftMargin) {
        NSLog(@"UIViewAutoresizingFlexibleLeftMargin");
    }
    if (type & UIViewAutoresizingFlexibleWidth) {
        NSLog(@"UIViewAutoresizingFlexibleWidth");
    }
    if (type & UIViewAutoresizingFlexibleRightMargin) {
        NSLog(@"UIViewAutoresizingFlexibleRightMargin");
    }
    if (type & UIViewAutoresizingFlexibleTopMargin) {
        NSLog(@"UIViewAutoresizingFlexibleTopMargin");
    }
    if (type & UIViewAutoresizingFlexibleHeight) {
        NSLog(@"UIViewAutoresizingFlexibleHeight");
    }
    if (type & UIViewAutoresizingFlexibleBottomMargin) {
        NSLog(@"UIViewAutoresizingFlexibleBottomMargin");
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self todo:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight];
}
结果输出
UIViewAutoresizingFlexibleLeftMargin
UIViewAutoresizingFlexibleRightMargin
UIViewAutoresizingFlexibleHeight
```

#### 2.命名规范
```
1.变量: 驼峰命名,类名开头
	static const NSTimeInterval ZOCSignInViewControllerFadeOutAnimationDuration = 0.4;

	/*static NSString const * kUserName = static NSString const (* kUserName )
     kUserName为指针, *kUserName是指针指向的地址的内容
     static NSString const * kUserName代表常量指针:指针必须指向任意一个常量
     */
    static NSString const *kUserName = @"kUserName";
    NSLog(@"kUserName = %p,*kUserName = %p",&kUserName,&(*kUserName));
    kUserName = @"OtherName";
    NSLog(@"kUserName = %p,*kUserName = %p",&kUserName,&(*kUserName));

    /*static NSString *const kUserName = static NSString  * const (kUserName)
     kUserName为指针常量
     */
    static NSString *const name = @"name";
	//name = @"kfkfkfk";//错误

2.方法
  类(-/+)间应该以空格间隔,方法段之间也应该用空格隔开
  尽可能少用and作为方法段名
  - (instancetype)initWith:(int)width and:(int)height; // Never do this.
  推荐一下写法:
  - (void)setExampleText:(NSString *)text image:(UIImage *)image;
  - (void)sendAction:(SEL)aSelector to:(id)anObject forAllCells:(BOOL)flag; - (id)viewWithTag:(NSInteger)tag;
  - (instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height;


```

#### 3.类
```
1.类名: 头三个字母最好是大写,避免与头两个字母是大写的苹果官方类冲突
2.initializer
	alloc 负责创建对象，这个过程包括分配足够的内存来保存对象，写入 isa 指针，初始化引用计数，以及重置所有实例变量。
	init 负责初始化对象，这意味着使对象处于可用状态。这通常意味着为对象的实例变量赋予合理有用的值。
3.designated initializer secondary initializer:一个直接,多个间接.
4.单例:
	+ (instancetype)sharedInstance {
		static id sharedInstance = nil;
		static dispatch_once_t onceToken = 0;
		dispatch_once(&onceToken, ^{
			sharedInstance = [[self alloc] init];
		});
		return sharedInstance;
	}
5.属性:
@property (assign, getter=isEditable) BOOL editable;

6.方法:
参数断言:判断某个参数是否满足条件,使用NSParameterAssert(),debug默认开启,release默认关闭
    NSInteger a = 10;
    NSParameterAssert(a> 1 && a > 10);
自定义私有方法:不要以_开头,_是苹果保留的,不能冒重载私有方法的险

7.分类:在分类方法名加上前缀,在编写静态库时,一定要注意加上前缀,防止与使用者冲突;发生冲突的时候将会以加载顺序最后的分类方法生效
@interface NSDate (ZOCTimeExtensions)
- (NSString *)zoc_timeAgoShort;

8.通知:
// Foo.h
UIKIT_EXTERN NSString * const ZOCFooDidBecomeBarNotification
// Foo.m
NSString * const ZOCFooDidBecomeBarNotification = @"ZOCFooDidBecomeBarNotification";
@end

9.代理优化:从面向对象到面向协议,只需要遵守ZOCFeedParserProtocol.h的对象
- (instancetype)initWithFeedParser:(id<ZOCFeedParserProtocol>)feedParser;

@protocol ZOCFeedParserDelegate;

@protocol ZOCFeedParserProtocol <NSObject>
@property (nonatomic, weak) id <ZOCFeedParserDelegate> delegate;
@property (nonatomic, strong) NSURL *url;

- (BOOL)start;
- (void)stop;
@end

@protocol ZOCFeedParserDelegate <NSObject>
@optional
- (void)feedParserDidStart:(id<ZOCFeedParserProtocol>)parser;
- (void)feedParser:(id<ZOCFeedParserProtocol>)parser didParseFeedInfo:(id)info;
- (void)feedParser:(id<ZOCFeedParserProtocol>)parser didParseFeedItem:(id)item;
- (void)feedParserDidFinish:(id<ZOCFeedParserProtocol>)parser;
- (void)feedParser:(id<ZOCFeedParserProtocol>)parser didFailWithError:(NSError *)error;


```
![SamuelChan/20170630192229.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170630192229.png)

#### 4.美化代码
```
1.方法的大括号和其他(if/else/switch/while)在同一行开始,新起一行结束
2.应该总是让冒号对齐。有一些方法签名可能超过三个冒号，用冒号对齐可以让代码更具有可读性。即使有代码块存在，也应该用冒号对齐方法。
	[UIView animateWithDuration:1.0
             	 	 animations:^{
                  	   // something
               	  	}
                 	 completion:^(BOOL finished) {
                       // something
                 	}];
```

#### 5.代码组织
```
1.利用代码块:代码块如果在闭合的圆括号中的话,会返回最后的值
NSURL *url = ({
	NSString *urlString = [NSString stringWithFormat:@"%@/%@", baseURLString, endpoint];
	[NSURL URLWithString:urlString];
});
2.#pragma mark - 是一个在类内部组织代码并且帮助你分组方法实现的好办法

3.当你调用NSSelectorFromString的时候,编译器不确定它是否会造成内存泄露,会报警告:performSelector may cause a leak because its selector is unknown. 如果确定不会泄露,那么就加上下面的代码忽略警告
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [self performSelector:NSSelectorFromString(@"testtest") withObject:@""];
	#pragma clang diagnostic pop

4.人为明确编译器的警告和错误:
#error Whoa, buddy, you need to check for zero here!
#warning Dude, don't compare floating point numbers like this!

5.注释相关:
没有参数的方法使用"//"进行注释
只在.h中写注释
```

#### 6.对象之间的通讯
```
1. block
(1)把提供需要的数据和错误信息整合到一个单独的block中,比分别提供成功失败的要好
(NSURLSession/NSURLConnection)

- (void)downloadObjectsAtPath:(NSString *)path
completion:(void(^)(NSArray *objects, NSError *error))completion;


- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(nullable id)parameters
                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

(2)block在栈上创建

(3)可复制到堆上: block作为属性,MRC下需要使用copy来将它拷贝到堆上;
            ARC下只是为了一致性将block属性声明为copy,编译器会自动将block拷贝到堆上

(4)block会捕获栈上的变量(指针),将其复制为自己私有的const变量
(5)如果要修改block中的变量(指针),那么变量和指针必须使用__block关键字声明:__block变量的栈变量被复制到堆上,复制完成后,block将会引用的是这份已经在堆上的副本
(6)使用:
 - 直接在 block 里面使用关键词 self:  只能在 block 不是作为一个 property 的时候使用，否则会导致 retain cycle。
 - 在 block 外定义一个 __weak 的 引用到 self，并且在 block 里面使用这个弱引用: 当 block 被声明为一个 property 的时候使用。
 - 在 block 外定义一个 __weak 的 引用到 self，并在在 block 内部通过这个弱引用定义一个 __strong 的引用。: 和并发执行有关。当涉及异步的服务的时候，block 可以在之后被执行，并且不会发生关于 self 是否存在的问题,保证在block执行期间引用的对象不被置为nil,但是也可能存在block执行时对象已经为空

2.DataSource和delegate   ---  委托者 vs 代理者
(1)代理方法的第一个参数必须是调用代理者:否则没有办法区分不同的委托者
(2)	@required @optional 默认的代理方法为@required
	if ([self.delegate 	respondsToSelector:@selector(signUpViewControllerDidPressSignUpButton:	)]) {
		[self.delegate signUpViewControllerDidPressSignUpButton:self];
	}
(3)继承代理实现:
继承关系:UIViewControllerB < UIViewControllerA < UIViewController
UIViewControllerA.h遵守UITableViewDelegate
UIViewControllerB.m想要重写UITableViewDelegate
- 如果代理方法是必须实现的话, UIViewControllerB可以直接call [super ...]
- 如果是@optional的代理方法, UIViewControllerB必须检查UIViewControllerA是否有实现
	- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
		CGFloat retVal = 0;
		if ([[UIViewControllerA class] instancesRespondToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
		retVal = [super tableView:self.tableView heightForRowAtIndexPath:indexPath];
		}
		return retVal + 10.0f;
	}
参考资料:http://devetc.org/code/2014/03/02/subclassing-delegates.html#fn:_cmd-arg(在相同方法中@selector(xxx) == _cmd)
```

#### 7.多重代理
1. 多个代理对象由一个proxy类来管理,proxy作为委托者的delegate
2. proxy并没有实现代理回调,所以这里需要使用到运行时的相关方法
![SamuelChan/20170704113634.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170704113634.png)
3. 相关代码  

```
(1)设置proxy代理
    _multipleDelegate = [MultipleDelegate new];
    //添加要处理delegate方法的对象
    NSArray *array = @[self, [ScrollDelegate new]];
    _multipleDelegate.allDelegates = array;
    self.scrollView.delegate = (id)_multipleDelegate;
(2)防止强引用
- (void)setDelegateTargets:(NSArray *)delegateTargets{
    self.weakRefTargets = [NSPointerArray weakObjectsPointerArray];
    for (id delegate in delegateTargets) {
        [self.weakRefTargets addPointer:(__bridge void *)delegate];
    }
}
(3)分发代理方法:
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        for (id target in self.allDelegates) {
            if ((signature = [target methodSignatureForSelector:aSelector])) {
                break;
            }
        }
    }
    return signature;
}
 
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    for (id target in self.allDelegates) {
        if ([target respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:target];
        }
    }
}

由于我们调用delegate的方法时，一般会先调用[delegate responseToSelector]方法，所以，我们还需要实现这个方法：
- (BOOL)respondsToSelector:(SEL)aSelector{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    for (id target in self.allDelegates) {
        if ([target respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}  
@end
```
[多个代理资料](http://www.cocoachina.com/ios/20151208/14595.html)
