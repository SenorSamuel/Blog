### Chapeter 1. Accustoming Yourself to ObjectiveC
---
#### Item 1: Familiarize Yourself with ObjectiveC’s Roots

- uses Messaging Structure rather than Function Calling
- the runtime decides which code gets executed. With function calling, the compiler decides which code will be executed: `virtual table`  vs `dynamic binding`(method and object type)
- **The ObjectiveC runtime component** contains all the data structures and functions that are required for the object-oriented features,**which glues together all your code and link as the form of a dynamic library.** your application benefits from the perfomance improvements as long as runtime is updated, while the other languages require recompiled
- All the features in C in available in ObjectiveC
- NSString *someString = @"The string".  
	someString: pointer are created at stack, pointer value == the memery address of the NSString instance

#### Item2 Minimize Importing Headers in Headers
1. 编译一个使用了EOCPerson类的文件时,不需要知道EOCEmployer类的全部细节,只需要知道一个类名叫EOCEmployer就好		
	向前声明(forward declaring): @class EOCEmployer;				
	优点: 降低类之间耦合(coupling),减少编译时间

2. 接口协议,一般在.h中,是在不行,就单独放在一个文件中,将其引入

#### Item3 多用 字面量语法 == 语法糖 ,少用与之等价的方法

```ojbc
1. 数值
NSNumber *intNumber = @1;
NSNumber *floatNumber = @2.5f;
NSNumber *doubleNumber = @3.14159;
NSNumber *boolNumber = @YES;
NSNumber *charNumber = @'a';
2. 数组
NSArray *animals = [NSArray arrayWithObjects:@"cat", @"dog",@"mouse", @"badger", nil];
NSArray *animals = @[@"cat", @"dog", @"mouse", @"badger"];

NSString *dog = [animals objectAtIndex:1];
NSString *dog = animals[1];

这种方式创建的数组,若数组元素对象中有nil,则会抛出异常,
从最终得到的数据安全来说,字面量语法更为安全
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '***
- [__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[0]

3.字典: 必须保证使用语法糖时,value不为空
NSDictionary *personData = @{@"firstName" : @"Matt",
							@"lastName" : @"Galloway",
						       @"age" : @28};

4.可变数组
mutableArray[1] = @"dog";
mutableDictionary[@"lastName"] = @"Galloway";

5.局限性
NSArray,NSDictionary,NSNumber(class cluster)的子类都无法使用语法糖
语法糖创建出来的NSString,NSArray,NSDictionary都是不可变的
```

#### Item4 多用类型常量,少用#define预处理指令
- 比起#define,编译可以在使用常量时进行类型检查
- Objective C中编译单元(translation unit)就是指一个实现文件(implementation file),编译器每收到一个编译单元,就会输出一份"目标文件"(object file)
- static const NSTimeInterval kAnimationDuration = 0.3;

	(1) static的作用是指明kAnimationDuration是作用在某个.m编译单元内, 此时编译器不会创建符号,而是会像#define预处理指令一样,把所有遇到的变量都替换成常值;   	
	(2) 如果在.m中不加static,那么编译器会为他创建一个"外部符号"(external symbol),如果另一个编译单元中也声明了同名变量,就会报`duplicate symbol _kAnimationDuration`的错误
- 对外公开某个变量,该常量会放在"data section"常量区,
	.h: 	UIKIT_EXTERN NSString *const WalletDidLoginNotification;
	.m:  NSString *const WalletDidLoginNotification = @"WalletDidLoginNotification";


#### Item5 用枚举表示状态,选项,状态码
- 如果枚举的值同时会被使用,使用位运算组合起来
- 处理枚举类型的switch语句不要实现default分支,这样加入新枚举之后,编译器会提示开发者:switch语句并未处理所有的枚举

```obj
//c语言写法
enum UIViewAutoresizing {
	UIViewAutoresizingNone = 0,
	UIViewAutoresizingFlexibleLeftMargin = 1 << 0,
	UIViewAutoresizingFlexibleWidth = 1 << 1,
	UIViewAutoresizingFlexibleRightMargin = 1 << 2,
	UIViewAutoresizingFlexibleTopMargin = 1 << 3,
	UIViewAutoresizingFlexibleHeight = 1 << 4,
	UIViewAutoresizingFlexibleBottomMargin = 1 << 5,
}

//Foundation写法,好处:可以声明枚举的数据结构
typedef NS_ENUM(NSUInteger, EOCConnectionState) {
	EOCConnectionStateDisconnected,
	EOCConnectionStateConnecting,
	EOCConnectionStateConnected,
};

typedef NS_OPTIONS(NSUInteger, EOCPermittedDirection) {
	EOCPermittedDirectionUp = 1 << 0,
	EOCPermittedDirectionDown = 1 << 1,
	EOCPermittedDirectionLeft = 1 << 2,
	EOCPermittedDirectionRight = 1 << 3,
};
```
![SamuelChan/20180615113652.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180615113652.png)

---
### Chapter2 对象,消息,运行期
---

#### Item6 理解"属性"这一概念
1. 属性: 用于封装对象的实例变量,通过setter,getter来访问, 实例变量是保存对象真正所需要的数据
2. 实例变量保管在类对象中(class object),减少每个对象都有一模一样的"偏移量"(实例变量内存地址).
3. ABI: Application Binary Interface,
4. @synthesize的作用:  生成属性的getter,setter声明和实现,默认为该类添加一个带下划线的实例变量
5. @property:
	- readwrite,readonly: readonly不会生成setter方法
	- @property在iOS中只使用nonatomic,如果有多线程操作数据,使用锁来保证线程同步
	- atomic和nonatomic的区别是: atomic保证了有且只有一个线程进行setter,getter操作,但是却**无法保证线程安全**,因为多个线程可以读写该属性,造成线程不安全.(线程A getter→线程B setter → 线程不同步)
	
	线程安全: 当我们讨论多线程安全的时候，其实是在讨论多个线程同时访问一个内存区域的安全问题
	
	大部分关于线程安全的文章都说的非常片面,**推荐Mr_Peak老师这篇文章,深入浅出解释**[iOS多线程到底不安全在哪里?](http://mrpeak.cn/blog/ios-thread-safety/)


#### Item7 在对象内部尽量直接访问实例变量
- ~~读取数据时,通过实例变量来读,而写入数据时,则应通过属性来写~~
- 初始化方法移动通过实例变量来读写数据
- 懒加载时,一定通过属性来getter数据

#### Item8 理解"对象等同性"
1. NSObject类对这两个方法的`默认实现`是: 当且仅当其"指针值"完全相等时,这两个对象才相等. 
	
	若想在`自定义的对象`中正确覆写这些方法,就必须先理解其contract : `如果"isEqual: "方法判定两个对象相等, 那么其hash方法也必须返回同一个值. 但是,hash方法返回同一个值的两个对象不一定相等`
2. 自定义对象判断相等性best practice
Person: `firstName` `lastName` `age`

```objc
-(BOOL)isEqual:(id)object{
    
    if ([self class] == [object class]) {
        return [self isEqualToPerson:object];
    }else{
        return [super isEqual:object];
    }
}

-(BOOL)isEqualToPerson:(Person *)person{
    
    if (self == person) return YES;
    
    if ([self class] != [person class]) return NO;
    
    BOOL hasEqualFirstName = (!self.firstName && !person.firstName) || ([self.firstName isEqualToString:person.firstName]);
    BOOL hasEqualLastName  = (!self.lastName && !person.lastName) || ([self.lastName isEqualToString:person.lastName]);
    BOOL hasEqualAge       = (self.age == person.age);
    
    return hasEqualFirstName && hasEqualLastName && hasEqualAge;
}

-(NSUInteger)hash{
    
    return [self.firstName hash] ^ [self.lastName hash] ^ self.age;//99%
}

```

3. isEqual不一样要判断所有的属性都相等,
4. 容器中可变类的等同性

参考文章 : [Equality by Mattt Thompson](http://nshipster.cn/equality/)

#### Item9 使用"类簇默认"隐藏实现细节

#### Item10 关联对象的使用
- 使用场景: 1.为分类添加属性  2.防止方法多次重入
- 为分类添加属性: .h中@property声明一个属性后,运行会报错:找不到selector,这是因为category不会为为该属性自动合成,
- 语法:

```objc
enum {
        OBJC_ASSOCIATION_ASSIGN = 0,          // 等价于 @property (assign) 或 @property (unsafe_unretained)
        OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,// 等价于 @property (nonatomic, strong)
        OBJC_ASSOCIATION_COPY_NONATOMIC = 3,  // 等价于 @property (nonatomic, copy)
        OBJC_ASSOCIATION_RETAIN = 01401,      // 等价于 @property (atomic, strong)
        OBJC_ASSOCIATION_COPY = 01403         // 等价于 @property (atomic, copy)
};
// 用key将object和value关联起来
// key: 一般使用@selector(属性名)作为key, @selector返回hash方法名的c字符串
void objc_setAssociatedObject(id object, void *key, id value,objc_AssociationPolicy policy)
id objc_getAssociatedObject(id object, void *key)
// 移除对象object的所有关联对象
void objc_removeAssociatedObjects(id object)

//例子
.h
@interface NSObject (secretary)
@property (nonatomic, copy) NSString *secretaryName;
@end
.m
#import <objc/runtime.h>
@implementation NSObject (secretary)
-(void)setSecretaryName:(NSString *)secretaryName {
    objc_setAssociatedObject(self, @selector(secretaryName), secretaryName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)secretaryName {
    return objc_getAssociatedObject(self, _cmd);
}

//防止多次调入同一个方法
@interface Engine : NSObject

@end

@implementation Engine

- (void)launch {
     // 在对象生命周期内, 不增加 flag 属性的情况下, 放置多次调进这个方法
     if (objc_getAssociatedObject(self, _cmd)) return;
     else objc_setAssociatedObject(self, _cmd, @"Launched", OBJC_ASSOCIATION_RETAIN);

     NSLog(@"launch only once");
}
@end
```
[Objective-C Runtime Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtInteracting.html#//apple_ref/doc/uid/TP40008048-CH103-SW1)

[Associated Objects by Mattt](http://nshipster.cn/associated-objects/)

[关联对象 AssociatedObject 完全解析 by Draveness](https://draveness.me/ao#关联对象的实现)


### Item11 理解objc_msgSend作用
- Objective-c的动态性:对象接受到消息之后,究竟该调用哪一个方法完全于运行期决定,甚至可以在程序运行时改变
- objc_msgSend

```objc
//原型:
/** 
 * Sends a message with a simple return value to an instance of a class.
 * 
 * @param self A pointer to the instance of the class that is to receive the message.
 * @param op The selector of the method that handles the message.
 * @param ... 
 *   A variable argument list containing the arguments to the method.
 * 
 * @return The return value of the method.
 * 
 * @note When it encounters a method call, the compiler generates a call to one of the
 *  functions \c objc_msgSend, \c objc_msgSend_stret, \c objc_msgSendSuper, or \c objc_msgSendSuper_stret.
 *  Messages sent to an object’s superclass (using the \c super keyword) are sent using \c objc_msgSendSuper; 
 *  other messages are sent using \c objc_msgSend. Methods that have data structures as return values
 *  are sent using \c objc_msgSendSuper_stret and \c objc_msgSend_stret.
 */
objc_msgSend(id _Nullable self, SEL _Nonnull op, parameters)

//example
id returnValue = objc_msgSend(someObject,@selector(messageName:),parameter);
 
objc_msgSend_stret   返回结构体 
objc_msgSend_fpret   返回浮点数
objc_msgSendSuper   给超类发消息
```

- objc_msgSend会搜索"方法列表",如果能找到与SEL的方法, 就跳转到实现代码(IMP),否则沿着继承体系继续向上查找,如果还是找不到就进入消息转发操作(message forwarding)

- objc_msgSend会缓存匹配结果在"快速映射表(fast map)"里面,每个类都有这样一块缓存,










