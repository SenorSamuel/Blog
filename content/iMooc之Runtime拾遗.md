## iMooc之Runtime拾遗

![SamuelChan/20180705220224.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180705220224.png)

### 0x01 数据结构

![SamuelChan/20180706113024.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180706113024.png)

### 0x02 类对象和元类对象

![SamuelChan/20180706114710.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180706114710.png)

### 0x03 消息传递

```objc
objc_msgSend(id _Nullable self, SEL _Nonnull op, ...)

objc_msgSendSuper(struct objc_super * _Nonnull super, SEL _Nonnull op, ...)

/// Specifies the superclass of an instance. 
struct objc_super {
    /// Specifies an instance of a class.
    __unsafe_unretained _Nonnull id receiver;

    /// Specifies the particular superclass of the instance to message. 
#if !defined(__cplusplus)  &&  !__OBJC2__
    /* For compatibility with old objc-runtime.h header */
    __unsafe_unretained _Nonnull Class class;
#else
    __unsafe_unretained _Nonnull Class super_class;
#endif
    /* super_class is the first class to search */
};

[self class]  && [super class]

objc_msgSend(self,@selector(class))
objc_msgSendSuper(super,,@selector(class))

```

![SamuelChan/20180706122456.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180706122456.png)

### 0x04 方法缓存

![SamuelChan/20180706121043.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180706121043.png)

如果在缓存中找不到方法,那么就会在`当前类`查找

- 对于`已排序好的列表`,采用`二分查找`算法查找方法所对应的执行函数IMP
- 对于`没有排序好的列表`,采用`一般遍历`算法查找方法所对应的执行函数IMP

### 0x05 消息转发
![SamuelChan/20170704113634.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170704113634.png)

```objc

+(BOOL)resolveInstanceMethod:(SEL)sel{
    
    if (sel == @selector(test)) {
        NSLog(@"%s", __FUNCTION__);
        return NO;
    }else{
        return [super resolveInstanceMethod:sel];
    }
}

-(id)forwardingTargetForSelector:(SEL)aSelector{
    
    if (aSelector == @selector(test)) {
        NSLog(@"%s", __FUNCTION__);
//        return [MObject new];
        return nil;
    }else{
        return [super forwardingTargetForSelector:aSelector];
    }
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    
    if (aSelector == @selector(test)) {
        NSLog(@"%s", __FUNCTION__);
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }else{
        return [super methodSignatureForSelector:aSelector];
    }
}

-(void)forwardInvocation:(NSInvocation *)anInvocation{
    
      [anInvocation invokeWithTarget:xxxx];
}
```

### 0x06 Method swizzling

```objc
#import <objc/runtime.h>
@implementation UIViewController (Tracking)
/*
 1.load : 类初始加载时调用
   initialize: 第一次调用类的类方法或实例方法之前被调用
  2.与上面相同，因为swizzling会改变全局状态，所以我们需要在运行时采取一些预防措施。原子
  性就是这样一种措施，它确保代码只被执行一次，不管有多少个线程。GCD的dispatch_once可
  以确保这种行为，我们应该将其作为method swizzling的最佳实践。
  3.总是调用方法的原始实现
  4.给自定义的分类方法加前缀，从而使其与所依赖的代码库不会存在命名冲突。
 */
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];         
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(xxx_viewWillAppear:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        //先调用 class_addMethod,为了防止swizzle掉父类的方法导致后面的swizzle出现隐藏的
        bug（有可能子类A 替换到方法func:，然后子类B 又把func替换回来）
        BOOL didAddMethod = class_addMethod(class,
                originalSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}
#pragma mark - Method Swizzling
- (void)xxx_viewWillAppear:(BOOL)animated {
    [self xxx_viewWillAppear:animated];//相同于调用了系统的viewWillAppear方法
    NSLog(@"viewWillAppear: %@", self);
}
@end

```

### 0x07 动态解析 → 添加方法

```objc
void test_imp (void) {
    
    NSLog(@"%s", __FUNCTION__);
}

+(BOOL)resolveInstanceMethod:(SEL)sel{
    
    if (sel == @selector(test)) {
        NSLog(@"%s", __FUNCTION__);
        
        //0x00 该方法能被动态解析
        class_addMethod(self, @selector(test), test_imp,"v@:");
        return YES;
        
        //0x01 进入备用消息转发者的流程
        //return NO;
    }else{
        return [super resolveInstanceMethod:sel];
    }
}

```



### 参考资料
[内存管理](http://yulingtianxia.com/blog/2015/12/06/The-Principle-of-Refenrence-Counting/#isa-指针)

[在 OC 中实现消息的一箭双雕](http://kittenyang.com/forwardinvocation/)

[多个代理资料](http://www.cocoachina.com/ios/20151208/14595.html)

[Method Swizzling](http://nshipster.com/method-swizzling/)


