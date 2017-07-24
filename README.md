
### 为什么写博客?

总结技术,沉淀,修炼内功
        
### 目录(倒序)
[Objective-C高级编程：iOS与OS X多线程和内存管理(Part1:MRC和ARC)](https://github.com/SenorSamuel/blog/issues/5)  
[禅与Objective-C编程艺术读书笔记](https://github.com/SenorSamuel/blog/issues/4)  
[应用评价总结](https://github.com/SenorSamuel/blog/issues/3)  
[app瘦身](https://github.com/SenorSamuel/blog/issues/2)  
[2017年年度计划](https://github.com/SenorSamuel/blog/issues/1)  

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Chapter1 Life Before Automatic Reference Counting](#chapter1-life-before-automatic-reference-counting)
  - [Reference Counted Memory Management Overview](#reference-counted-memory-management-overview)
  - [Exploring Memory Management Further](#exploring-memory-management-further)
    - [You Have Ownership of Any Objects You Create](#you-have-ownership-of-any-objects-you-create)
    - [You Can Take Ownership of an Object Using retain](#you-can-take-ownership-of-an-object-using-retain)
    - [When No Longer Needed, You Must Relinquish Ownership of an Object You Own](#when-no-longer-needed-you-must-relinquish-ownership-of-an-object-you-own)
    - [You Must Not Relinquish Ownership of an Object You Don’t Own](#you-must-not-relinquish-ownership-of-an-object-you-dont-own)
  - [Implementing alloc, retain, release, and dealloc](#implementing-alloc-retain-release-and-dealloc)
    - [GNUStep implementation](#gnustep-implementation)
    - [Apple’s Implementation of alloc, retain, release, and dealloc](#apples-implementation-of-alloc-retain-release-and-dealloc)
  - [Autorelease](#autorelease)
    - [Implementing autorelease](#implementing-autorelease)
- [Chapter2 ARC Rules](#chapter2-arc-rules)
  - [Ownership qualifiers](#ownership-qualifiers)
    - [1.__strong ownership qualifier](#1__strong-ownership-qualifier)
    - [2.__weak ownership qualifier](#2__weak-ownership-qualifier)
    - [3.__unsafe_unretained ownership qualifier](#3__unsafe_unretained-ownership-qualifier)
    - [4.__autoreleasing ownership qualifier](#4__autoreleasing-ownership-qualifier)
  - [Rules](#rules)
    - [Core Foundation](#core-foundation)
  - [Property](#property)
- [Chapter 3 ARC implementation](#chapter-3-arc-implementation)
  - [__strong](#__strong)
  - [__weak](#__weak)
  - [__autoreleasing](#__autoreleasing)
  - [Reference Count](#reference-count)
- [NSObject开源release,retain,dealloc内存管理的实现](#nsobject%E5%BC%80%E6%BA%90releaseretaindealloc%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86%E7%9A%84%E5%AE%9E%E7%8E%B0)
  - [引用计数的储存](#%E5%BC%95%E7%94%A8%E8%AE%A1%E6%95%B0%E7%9A%84%E5%82%A8%E5%AD%98)
  - [一些概念](#%E4%B8%80%E4%BA%9B%E6%A6%82%E5%BF%B5)
    - [1.TaggedPointer](#1taggedpointer)
    - [2.散列表](#2%E6%95%A3%E5%88%97%E8%A1%A8)
    - [3.retainCount](#3retaincount)
    - [4.retain](#4retain)
    - [5. release](#5-release)
    - [6. alloc](#6-alloc)
    - [7.dealloc](#7dealloc)
    - [8.autorelease](#8autorelease)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

>Problems:  
1. 一个非alloc/new/copy/muteCopy返回对象的方法应该由谁管理内存?  
2. AutoReleasePool也需要进行内存管理吗?如果要,谁来管理?

<h3 id="chapter1-life-before-automatic-reference-counting"> Chapter1 Life Before Automatic Reference Counting </h3>

---
#### Reference Counted Memory Management Overview
1. Memory Management(means Reference Counting in OC) : a programmer allocates a memory area when the program needs it and frees it when the program no longer needs it.  
2. Reference Counting: invented by George E. Collins in 1960
3. With Reference Counting,you don't need to remember the value of the reference counter itself or what refers to the object  
![SamuelChan/20170706152431.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170706152431.png)

#### Exploring Memory Management Further
1. Reference Counting Rules:
 - You have ownership of any objects you create.
 - You can take ownership of an object using retain.
 - When no longer needed, you must relinquish ownership of an object you own.
 - You must not relinquish ownership of an object you don’t own.

| Action for Objective-C Object   | Objective-C Method               |
| -----------------------------   | ------------------               |
| Create and have ownership of it | alloc/new/copy/mutableCopy group |
| Take ownership of it            | retain                           |
| Relinquish it                   | release                          |
| Dispose of it                   | dealloc                          |
> these method(alloc, retain, release, and dealloc) are not provided by the Objective-C language itself.They are features of the Foundation Framework as part of Cocoa Framework
![SamuelChan/20170706154549.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170706154549.png)

##### You Have Ownership of Any Objects You Create
```objc
// You create an object and have ownership.
id obj     = [[NSObject alloc] init];
id obj     = [NSObject new];
id objNew1 = [obj copy];//NSCopying protocol:copyWithZone:
id objNew2 = [obj mutableCopy];//NSMutableCopying protocol:mutableCopyWithZone:
//the naming convention is applied to:
  allocMyObject newThatObject copyThis mutableCopyYourObject
//the naming convention is not applied to:
  allocate  newer  copying  mutableCopyed
```

##### You Can Take Ownership of an Object Using retain
Sometimes methods that are not in the alloc/new/copy/mutableCopy method group return an object : you haven't create it, so you don't have ownership of it.

```objc
// Obtain an object without creating it yourself or having ownership   

id obj = [NSMutableArray array];
// The obtained object exists and you don’t have ownership of it,but you have a reference to NSMutableArray object.

[obj retain];
// The obtained object exists and you don’t have ownership of it.
```

##### When No Longer Needed, You Must Relinquish Ownership of an Object You Own
```objc
// 1.alloc -> relinquish
// You create an object and have ownership.
id obj = [[NSObject alloc] init];
// Now you have ownership of the object.
[obj release];
// The object is relinquished.Though the variable obj has the pointer to the object,you can’t access the object anymore.

// 2.retain -> relinquish
// Obtain an object without creating it yourself or having ownership
id obj = [NSMutableArray array];
// The obtained object exists and you don’t have ownership of it.
[obj retain];
// Now you have ownership of the object.
[obj release];
// The object is relinquished.You can’t access the object anymore.
```

**how a method return a created object?**
1. alloc/new/copy/muteableCopy : **If a method returns an object of which the methodhasownership,ownership is passed to the caller**

```objc
- (id)allocObject {
  // You create an object and have ownership.
  id obj = [[NSObject alloc] init];
  // At this moment, this method has ownership of the object.
  return obj;
}
```

2. [NSMutableArray array] : Returning a New Object Without Ownership.**By calling autorelease, you can return the created object without ownership** 可以返回,而不是为什么要返回没有ownership的(means by design)

```objc
- (id)object {
  id obj = [[NSObject alloc] init];
  /* At this moment, this method has ownership of the object. */

  [obj autorelease];
  /* The object exists, and you don’t have ownership of it. */
  return obj;
}
```
![SamuelChan/20170706173000.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170706173000.png)

##### You Must Not Relinquish Ownership of an Object You Don’t Own

```objc
id obj = [[NSObject alloc] init];
[obj release];
[obj release];//crash

id obj1 = [obj0 object];
[obj1 release];//crash sooner or later


/** why retainCount = -1 ? */
id obj2 = [NSArray array];
NSLog(@"%ld",[obj2 retainCount]);

id obj4 = [NSString string];
NSLog(@"%ld",[obj4 retainCount]);
```

#### Implementing alloc, retain, release, and dealloc
Although opensourced, I think this `guess` procedure still worth of being read so HERE WE GO.  

1. <del> But still, without having the implementation of NSObject itself, it is hard to see the whole picture </del>  :   [NSObject has been opensource](https://github.com/opensource-apple/objc4)  
2. CFFoundation is open-source,and the source code for memory management that is used from NSObject is public  
3. [GNUstep](https://en.wikipedia.org/wiki/GNUstep) is a free software implementation of the Cocoa (formerly OpenStep) Objective-C frameworks, widget toolkit, and application development tools for Unix-like operating systems and Microsoft Windows. It is part of the GNU Project.Although we can’t expect it to be exactly the same as Apple’s implementation, it works in the same manner and the implementation should be similar.**Understanding GNUstep source code helps us guess Apple’s Cocoa implementation**

##### GNUStep implementation
1.The alloc Method

```objc
struct obj_layout {
	NSUInteger retained;
};
+ (id) alloc {
	int size = sizeof(struct obj_layout) + size_of_the_object;
	//在堆上，分配n*size个字节，并初始化为0，返回void* 类型
	struct obj_layout *p = (struct obj_layout *)calloc(1, size);
	return (id)(p + 1);
}
```

2.The retain Method
![SamuelChan/20170707105639.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170707105639.png)

```objc
- (NSUInteger) retainCount {
    return NSExtraRefCount(self) + 1;
}
inline NSUInteger NSExtraRefCount(id anObject){
    return ((struct obj_layout *)anObject)[-1].retained; //移到头部
}

- (id) retain {
    NSIncrementExtraRefCount(self);
    return self;
}

inline void NSIncrementExtraRefCount(id anObject) {
   if (((struct obj_layout *)anObject)[-1].retained == UINT_MAX - 1)
   [NSException raise: NSInternalInconsistencyException format: @"NSIncrementExtraRefCount() asked increment too far"];
   ((struct obj_layout *)anObject)[-1].retained++;
}
```
3.The release Method

```objc
- (void) release {
  if (NSDecrementExtraRefCountWasZero(self))
  [self dealloc]; //dispose it
}

BOOL NSDecrementExtraRefCountWasZero(id anObject) {
  if (((struct obj_layout *)anObject)[-1].retained == 0) {
    return YES;
  } else {
    ((struct obj_layout *)anObject)[-1].retained--;
    return NO;
  }
}
```

4.The dealloc Method

```objc
- (void) dealloc {
  NSDeallocateObject (self);
}

inline void NSDeallocateObject(id anObject) {
  struct obj_layout *o = &((struct obj_layout *)anObject)[-1];
  free(o);
}
```


##### Apple’s Implementation of alloc, retain, release, and dealloc
1.The alloc method

```objc
+alloc
+allocWithZone:
class_createInstance
calloc
```
2.retainCount, retain, and release

```objc
-retainCount
__CFDoExternRefOperation
CFBasicHashGetCountOfKey

-retain
__CFDoExternRefOperation
CFBasicHashAddValue

-release
__CFDoExternRefOperation
CFBasicHashRemoveValue

int __CFDoExternRefOperation(uintptr_t op, id obj) {
  	CFBasicHashRef table = get hashtable from obj;
    int count;
    switch (op) {
      case OPERATION_retainCount:
        count = CFBasicHashGetCountOfKey(table, obj);
        return count;
      case OPERATION_retain:
        CFBasicHashAddValue(table, obj);
        return obj;
      case OPERATION_release:
        count = CFBasicHashRemoveValue(table, obj);
        return 0 == count;
    }
}

- (NSUInteger) retainCount {
  	return (NSUInteger)__CFDoExternRefOperation(OPERATION_retainCount, self);
}

- (id) retain {
  return (id)__CFDoExternRefOperation(OPERATION_retain, self);
}

- (void) release {
  return __CFDoExternRefOperation(OPERATION_release, self);
}

```

3.Apple implementation vs GNUStep implementation  
Benefits:  
GNUStep implementation:    

- Fewer codes  
- It is quite simple to manage the lifetime, because each memory area of the reference count itself is included in the object memory area

Apple implementation:

- Each object doesn't have a header, thus there is no need to worry about alignment issues for the header area
- By iterating through the hash table entries, memory blocks for each object are reachable.(useful for debugging,LLDB and Instruments)


![SamuelChan/20170707113104.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170707113104.png)
![SamuelChan/20170707113946.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170707113946.png)

#### Autorelease
1.Automatic Variables in C language:when left the variable scope,auto variable 'int a' is disposed of and can't be accessed anymore.

```c
{
  int a;
}
```

2.autoRelease:when execution leaves a code block, the “release” method is called on the object automatically

3.Caution:  
(1)临时处理多个对象的释放  
(2)类方法返回来一个没有ownership的对象  
(3)不要对NSAutoReleasePool发送autoRelease方法,因为它已经被override抛出exception  

```objc
//1. Create an NSAutoreleasePool object.
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//2. Call “autorelease” to allocated objects.
id obj = [[NSObject alloc] init];
[obj autorelease];

//3. Discard the NSAutoreleasePool object.
[pool drain];//will do [obj release]
```

![SamuelChan/20170707141849.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170707141849.png)  

No need to explicitly use the NSAutoreleasePool object in `the main Runloop`  

```objc
@autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
```
![SamuelChan/20170707142124.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170707142124.png)  

##### Implementing autorelease

```c++
class AutoreleasePoolPage {
  static inline void *push() {
    /* It corresponds to creation and ownership of an NSAutoreleasePool object */
  }

  static inline void pop(void *token) {
    /* It corresponds to disposal of an NSAutoreleasePool object */
    releaseAll();
  }

  static inline id autorelease(id obj) {
    /* It corresponds to NSAutoreleasePool class method addObject. */
    AutoreleasePoolPage *autoreleasePoolPage = /* getting active 	AutoreleasePoolPage object */
    autoreleasePoolPage->add(obj);
  }

  id *add(id obj) {
    /* add the obj to an internal array; */ }
    void releaseAll() {
      /* calls release for all the objects in the internal array */
    }
};

void *objc_autoreleasePoolPush(void) {
  return AutoreleasePoolPage::push();
}

void objc_autoreleasePoolPop(void *ctxt) {
  AutoreleasePoolPage::pop(ctxt);
}

id objc_autorelease(id obj) {
  return AutoreleasePoolPage::autorelease(obj);
}
```

<h3 id="chapter2-arc-rules"> Chapter2 ARC Rules </h3>

> Apple: Automatic Reference Counting (ARC) in Objective-C makes memory management the job of the compiler. By enabling ARC with the new Apple LLVM compiler, you will never need to type retain or release again, dramatically simplifying the development process, while reducing crashes and memory leaks. The compiler has a complete understanding of your objects, and releases each object the instant it is no longer used, so apps run as fast as ever, with predictable, smooth performance.1

ARC related:

- iOS 5 2011  
- Xcode Version >= 4.2  
- LLVM version  >= 3.0  
- Objective-C runtime library: objc4 493.9 or later
- ARC enabled: 1.Enabled ARC in build Setting 2.部分MRC:Build phases→Compile Sources→ -fno-objc-arc 3. Build phases→Compile Sources→部分ARC:-fobjc-arc   
![SamuelChan/20170717103437.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170717103437.png)



Chapter2组织方式:  

```objc
- the relationship of the reference counting rules with ARC  
- the ownership specifiers one by one  
- we learn the rules to make your code ARC-friendly: by simply following the rules
```

#### Ownership qualifiers
> With ARC,, ‘id’ and object type variables <mark>**must**</mark> have one of the following four ownership qualifiers:

- __strong  
- __weak  
- __unsafe _unretained     
- __autoreleasing

##### 1.__strong ownership qualifier

- __strong 代表了对象的ownership (MRC下对象需要通过alloc/new/copy/muteableCopy或者retain来获得ownership)

- __strong离开了{ }之后就会消失,即是说作用域在{ }之间

- 一个对象没有ownership将会被disposed

```objc
/* non-ARC */
{
  id obj = [[NSObject alloc] init];
  [obj release];
}

/* ARC */
{
  id __strong obj = [[NSObject alloc] init];
}

{
  id __strong obj = [NSMutableArray array];
}

//ownership is properly managed not only by variable scope, but also by assignments between variables
id __strong obj0 = [[NSObject alloc] init];
id __strong obj1 = [[NSObject alloc] init];
id __strong obj2 = nil;
obj0 = obj1;
obj2 = obj0;
obj1 = nil;
obj0 = nil;
obj2 = nil;

//By the way, any variables that are qualified with __strong, __weak, and __autoreleasing, are initialized with nil
id __strong obj0;
id __weak obj1;
id __autoreleasing obj2;
The above source code is equivalent to the following.
id __strong obj0 = nil;
id __weak obj1 = nil;
id __autoreleasing obj2 = nil;
```
##### 2.__weak ownership qualifier
> solve circular reference,self reference: A weak reference does not have ownership of the object.

> When a variable has a reference to an object and the object is discarded, the weak reference also disappears automatically, which means that the variable is assigned to <mark>nil</mark>.

![SamuelChan/20170711111007.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170711111007.png)

```objc
id __weak obj = [[NSObject alloc] init];//wrong,
//warning: assigning retained obj to weak variable; obj will be released after assignment [-Warc-unsafe-retained-assign]


id __strong obj0 = [[NSObject alloc] init];
id __weak obj1 = obj0;
```

##### 3.__unsafe_unretained ownership qualifier

```objc
__weak               : iOS5 (or later) or OSX Lion (or later)
__unsafe _unretained : before iOS5 or before OSX Lion

//__weak和__unsafe_unretained的区别在于:后者不会在对象无ownership之后自动置为nil
id __unsafe_unretained obj1 = nil;
{
  id __strong obj0 = [[NSObject alloc] init];
  obj1 = obj0;
  NSLog(@"A: %@", obj1);
}
NSLog(@"B: %@", obj1);//Crash:野指针,访问僵尸对象,报EXC_BAD_ADDRESS

FYI:
（1）野指针
①C语言:定义了一个指针变量，但是并没有赋初值，它随机指向一个东西
②Obj某指针变量指向的内存空间被释放掉了（指向僵尸对象的指针）

（2）僵尸对象
已经被销毁的对象（无法被使用的对象）

（3）空指针
没有指向存储空间的指针（里面存的是nil，也就是0）
给空指针发消息是没有任何反应的，不会提示出错

(4) EXC_BAD_ADDRESS ARC什么时候会出现?? Core-Foundation,混编,C++
```

##### 4.__autoreleasing ownership qualifier
![SamuelChan/20170711144133.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170711144133.png)
![SamuelChan/20170711144249.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170711144249.png)

- ①When an object is returned from a method, the compiler checks if the method begins with alloc/new/copy/mutableCopy, and if not, the returned object is automatically registered to the autorelease pool

- ②Exceptionally, any method whose name begins with init, doesn’t register the return value to autoreleasepool

```objc
@autoreleasepool {
//not in the alloc/new/copy/mutableCopy method group,register in autoReleasePool
	id __strong obj = [NSMutableArray array];
}

//“id obj” does not have a qualifier. So it is qualified with __strong. When the “return” sentence is executed, the variable scope is left and the strong reference disappears. Therefore the object will be released automatically. Before that, if the compiler detects that the object will be passed to the caller, the object is registered in autoreleasepool.

+ (id) array {
  id obj = [[NSMutableArray alloc] init];
  return obj;
}
```

- ③<del>the __weak ownership qualifier is used to avoid cyclic reference. When a variable with a __weak qualifier is used, the object is always registered in autoreleasepool.</del>  

	<del> Why does the object need to be registered in autoreleasepool in order to use the object via the __weak qualified variable? Because a variable, which is qualified with __weak,
 does not have a strong reference, the object might be disposed of at any point. If the object is registered in autoreleasepool, until @autoreleasepool block is left, the object must exist. So, to use the objects via __weak variable safely, the object is registered in autoreleasepool automatically.(**to be proved**) </del>

- ④ Any pointers to ‘id’ or object types are qualified with __autoreleasing as default.  

```objc
id obj 	       == id __strong obj;  
id *obj   	   == id __autoreleasing *obj;  
NSObject **obj == NSObject * __autoreleasing *obj  
-(BOOL) performOperationWithError:(NSError * __autoreleasing *)error;
```

5.Returning a Result as the Argument
>The caller will obtain the object as an argument, which means that the caller does not obtain it from the alloc/new/copy/mutableCopy method group. To follow the memory management rules, <mark>when you do not obtain an object by the alloc/new/copy/mutableCopy method group, the object has to be passed without ownership.</mark> By the __autoreleasing ownership qualifier, the rule is fulfilled.

```objc
- (BOOL) performOperationWithError:(NSError * __autoreleasing *)error {
  /* Error occurred. Set errorCode */
  return NO;
}

//To assign an object pointer, both ownership qualifiers have to be the same.
NSError __autoreleasing *error = nil;
NSError * __autoreleasing *pError = &error; /* No compile error */

//compile optimization(before)
NSError __strong *error = nil;
BOOL result = [obj performOperationWithError:&error];

//compile optimization(after)
NSError __strong *error = nil;
NSError __autoreleasing *tmp = error;
BOOL result = [obj performOperationWithError:&tmp];
error = tmp;
```

#### Rules

```objc
  1.Forget about using retain, release, retainCount, and autorelease.
  2.Forget about using NSAllocateObject and NSDeallocateObject.
  3.Follow the naming rule for methods related to object creation:
    create ownership:alloc/new/copy/mutableCopy/- (instanceType)initWithXXX
  4.Forget about calling dealloc explicitly.
 	  dealloc is a suitable place to remove the object from delegate or observers
  5.Use @autoreleasepool instead of NSAutoreleasePool.
  6.Forget about using Zone (NSZone)
    现在CPU的负载能力不需要NSZone这种会带来碎片化的机制
  7.Object type variables can’t be members of struct or union in C language.
```
8.‘id’ and ‘void*’ have to be cast explicitly.  
With ARC,To cast between ‘id’ or object types and 'void*',you can use __bridge

```objc
//dangerous: should be careful,since you don't know whether p have ownership or not.
id obj = [[NSObject alloc] init];   
void *p = (__bridge void *)obj;
id o = (__bridge id)p;

//__bridge dangling pointer example
void *p = nil;
{
  id obj = [NSObject new];
  p = (__bridge void *)obj;
}
NSLog(@"%@",(__bridge id)p);//错误,野指针
```

`__bridge_retained` 和 `__bridge_transfer` 都是用来解决`void *`的ownership的

```objc
//__bridge_retained:__bridge_retained cast works as if the assigned variable has ownership of the object
//example 1
id obj = [[NSObject alloc] init];
void *p = (__bridge_retained void *)obj;//pointer p也有ownership

//example 2
void *p = 0;
{
  id obj = [[NSObject alloc] init];
  p = (__bridge_retained void *)obj;
}

NSLog(@"class=%@", [(__bridge id)p class]);//after leave the scrope variable, p still have ownership
```

```objc
//__bridge_transfer:__bridge_transfer cast will release the object just after the assignment is done.
//example 1
id obj = (__bridge_transfer id)p;

//example 2
void *p = (__bridge_retained void *)[[NSObject alloc] init];
NSLog(@"class=%@", [(__bridge id)p class]);
(void)(__bridge_transfer id)p;
```

##### Core Foundation
> iOS的系统架构分为四个层次：核心操作系统层（Core OS layer）、核心服务层（Core Services layer）、媒体层（Media layer）和可触摸层（Cocoa Touch layer）。Core Foundation框架 (CoreFoundation.framework) 是一组C语言接口，它们为iOS应用程序提供基本数据管理和服务功能。位于第二层核心服务层
cocoa Foundation框架位于第四层。
[CoreFoundation](https://developer.apple.com/library/content/documentation/CoreFoundation/Conceptual/CFDesignConcepts/CFDesignConcepts.html#//apple_ref/doc/uid/10000122i)


OBJECTIVE-C OBJECT AND CORE FOUNDATION OBJECT  
1.Core Foundation,mainly written in C;has reference counting  
2.[Toll-Free Bridged Types](https://developer.apple.com/library/content/documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html#//apple_ref/doc/uid/TP40010677-SW1):There are a number of data types in the Core Foundation framework and the Foundation framework that can be used interchangeably. Data types that can be used interchangeably are also referred to as toll-free bridged data types

CFBridgingRetain function

```objc
CFTypeRef CFBridgingRetain(id X) {
  return (__bridge_retained CFTypeRef)X;
}
```

```objc
CFMutableArrayRef cfObject = NULL;
{
  id obj = [[NSMutableArray alloc] init];
  cfObject = CFBridgingRetain(obj);//warning...
  //cfObject =  (__bridge_retained CFMutableArrayRef)obj;//no warning
  CFShow(cfObject);
  printf("retain count = %d\n", CFGetRetainCount(cfObject));
}
printf("retain count after the scope = %d\n", 	CFGetRetainCount(cfObject)); CFRelease(cfObject);
```

```objc
CFMutableArrayRef cfObject = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
printf("retain count = %d\n", CFGetRetainCount(cfObject));
id obj = CFBridgingRelease(cfObject);
printf("retain count after the cast = %d\n",CFGetRetainCount(cfObject));
NSLog(@"class=%@", obj);
```


#### Property
Property modifier | Ownership qualifier
------------- | -------------
assign  | __unsafe _unretained
copy  | __strong (note: new copied object is assigned.)
retain | __strong
strong |__strong
unsafe_unretained | __unsafe _unretained
weak | __weak  


### Chapter 3 ARC implementation
---
#### __strong
```objc
{
  id __strong obj = [[NSObject alloc] init];
}

/* pseudo code by the compiler */
id obj = objc_msgSend(NSObject, @selector(alloc));
objc_msgSend(obj, @selector(init));
objc_release(obj);
```

an object is not obtained by the alloc/new/copy/mutableCopy

objc_retainAutoreleasedReturnValue:  
1. **`objc_retainAutoreleasedReturnValue`** function is for performance optimization. It is inserted because the NSMutableArray class method array is not in the alloc/new/copy/mutableCopy method group. `The compiler` inserts this function every time just after the invocation of a method if the method is not in the group. As the name suggests, it `retains` an object returned from a method or function after `the object is added in autorelease pool`.  
2. **`objc_retainAutoreleasedReturnValue`** function expects that an **`objc_autoreleaseReturnValue`** function has been called inside the method. Any methods, that are not in the alloc/new/copy/mutableCopy group, have to call **`objc_autoreleaseReturnValue`**

```objc
{
  id __strong obj = [NSMutableArray array];
}

/* pseudo code by the compiler */
id obj = objc_msgSend(NSMutableArray, @selector(array));
objc_retainAutoreleasedReturnValue(obj);
objc_release(obj);
```

objc_autoreleaseReturnValue
1. `objc_autoreleaseReturnValue` adds an object to autorelease pool and returns it
2. `objc_autoreleaseReturnValue` checks `the caller’s executable code` and if the code calls `objc_retainAutoreleasedReturnValue` just after calling this method: **it just returns the object to the caller,So, performance will be improved.**
	> 返回值身上调用objc_autoreleaseReturnValue方法时，runtime将这个返回值object储存在TLS中，然后直接返回这个object（不调用autorelease）；同时，在外部接收这个返回值的objc_retainAutoreleasedReturnValue里，发现TLS中正好存了这个对象，那么直接返回这个object（不调用retain）。于是乎，调用方和被调方利用TLS做中转，很有默契的免去了对返回值的内存管理。<mark>即是说如果确认方法返回值一定会被其他引用持有的话,那么就不需要放进缓存池</mark>



```objc
+ (id) array {
  return [[NSMutableArray alloc] init];
}

This source code is converted as follows. It calls objc_autoreleaseReturnValue function at the last.
/* pseudo code by the compiler */
+ (id) array
{
  id obj = objc_msgSend(NSMutableArray, @selector(alloc));
  objc_msgSend(obj, @selector(init));
  return objc_autoreleaseReturnValue(obj);
}
```

![SamuelChan/20170713155559.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170713155559.png)

#### __weak
- Nil is assigned to any variables qualified with __weak when referencing object is discarded.
- <del> When an object is accessed through a __weak qualified variable, the object is added to the autorelease pool:</del> wrong guide

```objc
/* example */
{
  id __weak obj1 = obj;
}
/* pseudo code by the compiler */
id obj1;
objc_initWeak(&obj1, obj); //call obj1 = 0; objc_storeWeak(&obj1, obj);
objc_destroyWeak(&obj1);   //call objc_storeWeak(&obj1, 0);
```

> `Hash table` : 我们知道，数组的最大特点就是：寻址容易，插入和删除困难；而链表正好相反，寻址困难，而插入和删除操作容易。那么如果能够结合两者的优点，做出一种寻址、插入和删除操作同样快速容易的数据结构，那该有多好。这就是哈希表创建的基本思想，而实际上哈希表也实现了这样的一个“夙愿”，哈希表就是这样一个集查找、插入和删除操作于一身的数据结构。  

`objc_storeWeak`:  

```objc
/**
 * This function stores a new value into a __weak variable. It would
 * be used anywhere a __weak variable is the target of an assignment.
 *
 * @param location The address of the weak pointer itself
 * @param newObj The new object this weak ptr should now point to
 *
 * @return \e newObj
 */
id objc_storeWeak(id *location, id newObj)

//when obj = 0,the entry remove from hash table
objc_storeWeak(&obj1, obj);

```
`When an Object Is Discarded`  

1. objc_release.
2. dealloc is called because retain count becomes zero.
3. _objc_rootDealloc.
4. object_dispose.
5. objc_destructInstance.
6. objc_clear_deallocating:
	1. From the weak table, get an entry of which the key is the object to be discarded.
	2. Set nil to all the __weak ownership qualified variables in the entry.
	3. Remove the entry from the table.
	4. For the object to be disposed of, remove its `key` from the **`reference table`**.

`Assigning a Newly Created Object`

```objc
{
  id __weak obj = [[NSObject alloc] init];
}

/* pseudo code by the compiler */
id obj;
id tmp = objc_msgSend(NSObject, @selector(alloc));
objc_msgSend(tmp, @selector(init));
objc_initWeak(&obj, tmp);
objc_release(tmp);
objc_destroyWeak(&object);
```

**<del>Adding to autorelease pool Automatically</del>**  
验证汇编代码: Xcode → Debug → Debug workflow → Always show Disassembly.
输入下面的例子,会看到编译器插入的是release不是autorelease

In conclusion, this design of __weak ensure that during the usage of weak pointer, its state is consistent. The `new` implmenetation of __weak of `Apple LLVM version 8.0.0 (clang-800.0.42.1)` do not postpond the release to autoreleasepool, but use `objc_release` **directly**.


```objc
{
  id __weak obj1 = obj;
  NSLog(@"%@", obj1);
}
/* iOS5及之前编译器做法 */
id obj1;
objc_initWeak(&obj1, obj);
id tmp = objc_loadWeakRetained(&obj1);
objc_autorelease(tmp);//错误!!!mistake
NSLog(@"%@", tmp);
objc_destroyWeak(&obj1);

/* 现在的编译器做法*/
id obj = objc_msgSend(NSObject, "new");
id obj1;
objc_initWeak(&obj1, obj);
id tmp = objc_loadWeakRetained(obj1);//objc_loadWeakRetained would increment the reference count to ensure that tmp is alive in the NSLog statement.
NSLog(@"%@", obj1);
objc_release(tmp);
objc_destroyWeak(&obj1);
objc_storeStrong(&obj, 0);//release
```

[苹果list](https://lists.apple.com/archives/objc-language/2012/Aug/msg00027.htm‌​l)  
[参考资料1](https://stackoverflow.com/questions/40993809/why-weak-object-will-be-added-to-autorelease-pool/41008619#41008619)  
[参考资料2](https://stackoverflow.com/questions/34083137/objective-c-weak-object-is-registered-in-autoreleasepool-automatically?rq=1)

#### __autoreleasing
```objc
@autoreleasepool {
  id __autoreleasing obj = [[NSObject alloc] init];
}

/* pseudo code by the compiler */
id pool = objc_autoreleasePoolPush();
id obj = objc_msgSend(NSObject, @selector(alloc));
objc_msgSend(obj, @selector(init));  
objc_autorelease(obj);    //放进自动释放池
objc_autoreleasePoolPop(pool);

@autoreleasepool {
  id __autoreleasing obj = [NSMutableArray array];
}

/* pseudo code by the compiler */
id pool = objc_autoreleasePoolPush();
id obj = objc_msgSend(NSMutableArray, @selector(array));
objc_retainAutoreleasedReturnValue(obj);
objc_autorelease(obj);
objc_autoreleasePoolPop(pool);
```


#### Reference Count
`uintptr_t _objc_rootRetainCount(id obj)`:don't return reliable value all the time


### NSObject开源release,retain,dealloc内存管理的实现
---
> 1. 本书本之前讨论的内存管理是基于GNUStep或者是CFFoundation里面的内存管理部分.现在NSObject已经开源了
> 2. [objc4-709](https://opensource.apple.com/tarballs/objc4/)

#### 引用计数的储存
有些对象如果支持使用`TaggedPointer`，苹果会直接将其指针值作为引用计数返回；否则 Runtime 会使用一张`散列表`来管理引用计数。

#### 一些概念
##### 1.TaggedPointer
判断当前对象是否在使用 TaggedPointer 是看标志位是否为 1;id的isTaggedPointer()方法经常会在操作引用计数时用到，因为这决定了存储引用计数的策略。

```c++
#if SUPPORT_MSB_TAGGED_POINTERS
#   define TAG_MASK (1ULL<<63)
#else
#   define TAG_MASK 1

inline bool
objc_object::isTaggedPointer()
{
#if SUPPORT_TAGGED_POINTERS
    return ((uintptr_t)this & TAG_MASK);
#else
    return false;
#endif
}
```

##### 2.散列表

```c++
struct SideTable {
    // 保证原子操作的自旋锁
    spinlock_t slock;
    // 引用计数的 hash 表
    RefcountMap refcnts;
    // weak 引用全局 hash 表
    weak_table_t weak_table;
};

SideTable 结构体重定了几个非常重要的变量。
// The order of these bits is important.
#define SIDE_TABLE_WEAKLY_REFERENCED (1UL<<0)    
#define SIDE_TABLE_DEALLOCATING      (1UL<<1)  // MSB-ward of weak bit
#define SIDE_TABLE_RC_ONE            (1UL<<2)  // MSB-ward of deallocating bit
#define SIDE_TABLE_RC_PINNED         (1UL<<(WORD_BITS-1))//最高位字节为0
#define SIDE_TABLE_RC_SHIFT 2
#define SIDE_TABLE_FLAG_MASK (SIDE_TABLE_RC_ONE-1)
```

![SamuelChan/20170717173215.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170717173215.png)

##### 3.retainCount
```objc
- (NSUInteger)retainCount {
    return ((id)self)->rootRetainCount();
}

inline uintptr_t
objc_object::rootRetainCount()
{
    if (isTaggedPointer()) return (uintptr_t)this;
    return sidetable_retainCount();
}

uintptr_t
objc_object::sidetable_retainCount()
{
    SideTable& table = SideTables()[this];
    size_t refcnt_result = 1;

    table.lock();
    RefcountMap::iterator it = table.refcnts.find(this);
    if (it != table.refcnts.end()) {
        // this is valid for SIDE_TABLE_RC_PINNED too
        refcnt_result += it->second >> SIDE_TABLE_RC_SHIFT;//右移两位
    }
    table.unlock();
    return refcnt_result;
}
```

##### 4.retain
```objc
- (id)retain {
    return ((id)self)->rootRetain();
}

// Base retain implementation, ignoring overrides.
// This does not check isa.fast_rr; if there is an RR override then
// it was already called and it chose to call [super retain].
inline id
objc_object::rootRetain()
{
    if (isTaggedPointer()) return (id)this;
    return sidetable_retain();
}

id
objc_object::sidetable_retain()
{
#if SUPPORT_NONPOINTER_ISA
    assert(!isa.nonpointer);
#endif
    SideTable& table = SideTables()[this];

    table.lock();
    size_t& refcntStorage = table.refcnts[this];
    if (! (refcntStorage & SIDE_TABLE_RC_PINNED)) {
    	//相当于+(1 << 2)
        refcntStorage += SIDE_TABLE_RC_ONE;
    }
    table.unlock();
    return (id)this;
}

```

##### 5. release
```objc
- (oneway void)release {
    ((id)self)->rootRelease();
}

inline bool
objc_object::rootRelease()
{
    if (isTaggedPointer()) return false;
    return sidetable_release(true);
}

// rdar://20206767
// return uintptr_t instead of bool so that the various raw-isa
// -release paths all return zero in eax
uintptr_t
objc_object::sidetable_release(bool performDealloc)
{
#if SUPPORT_NONPOINTER_ISA
    assert(!isa.nonpointer);
#endif
    SideTable& table = SideTables()[this];
    bool do_dealloc = false;
    table.lock();
    RefcountMap::iterator it = table.refcnts.find(this);
    if (it == table.refcnts.end()) {
        do_dealloc = true;
        table.refcnts[this] = SIDE_TABLE_DEALLOCATING;
    } else if (it->second < SIDE_TABLE_DEALLOCATING) {
        // 判断引用计数是否为0,如果小于SIDE_TABLE_DEALLOCATING,只有00000001或者00000000,两种情况下,引用计数都为0,所以需要将do_dealloc置为0
        // SIDE_TABLE_WEAKLY_REFERENCED may be set. Don't change it.
        do_dealloc = true;
        it->second |= SIDE_TABLE_DEALLOCATING;
    } else if (! (it->second & SIDE_TABLE_RC_PINNED)) {
    	 // 如果符合这个条件,即:引用计数没有溢出(最高位为0),do_dealloc为0,weak_reference为0)
        it->second -= SIDE_TABLE_RC_ONE;
    }
    table.unlock();
    if (do_dealloc  &&  performDealloc) {
        ((void(*)(objc_object *, SEL))objc_msgSend)(this, SEL_dealloc);
    }
    return do_dealloc;
}

```

##### 6. alloc
```objc
+alloc
+allocWithZone:
class_createInstance
calloc
```

##### 7.dealloc
1. objc_release.
2. dealloc is called because retain count becomes zero.
3. _objc_rootDealloc.
4. object_dispose.
5. objc_destructInstance
6. objc_clear_deallocating:
	1. From the weak table, get an entry of which the key is the object to be discarded.
	2. Set nil to all the __weak ownership qualified variables in the entry.
	3. Remove the entry from the table.
	4. For the object to be disposed of, remove its `key` from the **`reference table`**

##### 8.autorelease
参考资料:  
[黑幕背后的Autorelease](http://blog.sunnyxx.com/2014/10/15/behind-autorelease/)

- Autorelease对象什么时候释放？
在没有手加Autorelease Pool的情况下，Autorelease对象是在当前的runloop迭代结束时释放的，而它能够释放的原因是系统在每个runloop迭代中都加入了自动释放池Push和Pop
- AutoreleasePoolPage:是一个C++实现的类,
![SamuelChan/20170717194057.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170717194057.png)
 - 	AutoreleasePool并没有单独的结构，而是由若干个AutoreleasePoolPage以[双向链表](http://www.cnblogs.com/skywang12345/p/3561803.html#a31)的形式组合而成（分别对应结构中的parent指针和child指针）
 -  AutoreleasePool是按线程一一对应的（结构中的thread指针指向当前线程）
 -  AutoreleasePoolPage每个对象会开辟4096字节内存（也就是虚拟内存一页的大小），除了上面的实例变量所占空间，剩下的空间全部用来储存autorelease对象的地址
 -  上面的id *next指针作为游标指向栈顶最新add进来的autorelease对象的下一个位置
 -  一个AutoreleasePoolPage的空间被占满时，会新建一个AutoreleasePoolPage对象，连接链表，后来的autorelease对象在新的page加入
- AutoreleasePoolPage快要满的时候:也就是next指针马上指向栈顶，这时就要执行上面说的操作，建立下一页page对象，与这一页链表连接完成后，新page的next指针被初始化在栈底（begin的位置），然后继续向栈顶添加新对象。

![SamuelChan/20170717194341.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170717194341.png)

- 释放时刻:根据哨兵位置进行pop释放池,每当进行一次objc_autoreleasePoolPush调用时，runtime向当前的AutoreleasePoolPage中add进一个哨兵对象，值为0（也就是个nil）
![SamuelChan/20170717194612.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170717194612.png)

```objc
void *context = objc_autoreleasePoolPush();
// {}中的代码
objc_autoreleasePoolPop(context);
```

- 使用容器的block版本的枚举器时，内部会自动添加一个AutoreleasePool,普通for/for in中没有  
```objc
 [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    // 这里被一个局部@autoreleasepool包围着
}];
```




参考资料:  
1.[Objective-C 引用计数原理](http://yulingtianxia.com/blog/2015/12/06/The-Principle-of-Refenrence-Counting/),部分地方最新的obj4版本已经改了   
2.[iOS进阶——iOS（Objective-C）内存管理·二
](http://zhoulingyu.com/2017/02/15/Advanced-iOS-Study-objc-Memory-2/)
