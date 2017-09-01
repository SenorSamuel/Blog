- [ Chapter 4 Getting Started with Blocks ](#chapter-4-getting-started-with-blocks)
  - [ Blocks Primer (Blocks入门) ](#blocks-primer-blocks%E5%85%A5%E9%97%A8)
    - [ 1.anonymous functions ](#1anonymous-functions)
    - [ 2.automatic(local) variables ](#2automaticlocal-variables)
  - [ Block synax ](#block-synax)
- [ Chapter 5 Blocks Implementation ](#chapter-5-blocks-implementation)
  - [ 1.Block的实现 ](#1block%E7%9A%84%E5%AE%9E%E7%8E%B0)
    - [ 1.1 常规的block ](#11-%E5%B8%B8%E8%A7%84%E7%9A%84block)
    - [ 1.2 捕获自动变量的block实现 ](#12-%E6%8D%95%E8%8E%B7%E8%87%AA%E5%8A%A8%E5%8F%98%E9%87%8F%E7%9A%84block%E5%AE%9E%E7%8E%B0)
    - [ 1.3 捕获__block修饰的栈变量 ](#13-%E6%8D%95%E8%8E%B7__block%E4%BF%AE%E9%A5%B0%E7%9A%84%E6%A0%88%E5%8F%98%E9%87%8F)
    - [ 1.4 捕获对象的实现(没__block修饰) ](#14-%E6%8D%95%E8%8E%B7%E5%AF%B9%E8%B1%A1%E7%9A%84%E5%AE%9E%E7%8E%B0%E6%B2%A1__block%E4%BF%AE%E9%A5%B0)
    - [ 1.5 捕获__block修饰的对象 ](#15-%E6%8D%95%E8%8E%B7__block%E4%BF%AE%E9%A5%B0%E7%9A%84%E5%AF%B9%E8%B1%A1)
  - [ 2.Block的储存 ](#2block%E7%9A%84%E5%82%A8%E5%AD%98)
    - [ 2.1 _NSConcreteGlobalBlock ](#21-_nsconcreteglobalblock)
    - [ 2.2 _NSConcreteStackBlock ](#22-_nsconcretestackblock)
    - [ 2.3 _NSConcreteMallocBlock ](#23-_nsconcretemallocblock)
    - [2.4__block变量的内存分析](#24-__block%E5%8F%98%E9%87%8F%E7%9A%84%E5%86%85%E5%AD%98%E5%88%86%E6%9E%90)
    - [ 2.5 三种block与copy的关系 ](#25-%E4%B8%89%E7%A7%8Dblock%E4%B8%8Ecopy%E7%9A%84%E5%85%B3%E7%B3%BB)
  - [ 3.循环引用问题 ](#3%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8%E9%97%AE%E9%A2%98)
    - [ 3.1 问题的发生 ](#31-%E9%97%AE%E9%A2%98%E7%9A%84%E5%8F%91%E7%94%9F)
    - [ 3.2 观点 ](#32-%E8%A7%82%E7%82%B9)

##Chapter 4 Getting Started with Blocks

### Blocks Primer (Blocks入门)

> can be explained as "**<mark>anonymous functions</mark>**" together with "**<mark>automatic (local) variables.<mark>**"

Block理解:  

- 底层是一个对象, 相当于是一个匿名的函数指针,可以减少代码量
- 捕获所用到的变量

#### 1.anonymous functions

匿名函数  
C和Objective-c中:Block;	C++:introduced in C++11  
[指针函数和函数指针](http://yulingtianxia.com/blog/2014/04/17/han-shu-zhi-zhen-yu-zhi-zhen-han-shu/)
> int *pfun(int, int);    

> int *(pfun(int, int)); //函数指针:返回值是一个指针的函数pfun();   

> int (*pfun)(int, int); //指针函数:指向函数的一个指针;


```objc
int func(int count);

//call the function
int result = func(10);

//use function pointer
int (*funcptr)(int) = &func; 
int result = funcptr(10);
```

#### 2.automatic(local) variables

C语言中的变量:  
static, static global, and global:在函数外值可以保持不变,他们在内存的静态区;  
Automatic variables              :局部变量,作用于在{}之间

- Automatic variables (local variables)
- Function arguments
- Static variables (static local variables)
- Static global variables
- Global variables

### Block synax

> **无参无返回值**:  
> **无参有返回值**:  
> **有参无返回值**:  
> **有参有返回值**:  

[How Do I Declare A Block in Objective-C?](http://out.easycounter.com/external/fuckingblocksyntax.com)

```objc
//只要是定义一个block变量,就是先写返回值;
//如果是定义一个block,先写 ^
//1.As a local variable:
returnType (^blockName)(parameterTypes) = ^returnType(parameters){...};

//2.As a property:
@property (nonatomic, copy, nullability) returnType (^blockName)(parameterTypes);

//3.As a method parameter:
- (void)someMethodThatTakesABlock:(returnType (^nullability)(parameterTypes))blockName;

//4.As an argument to a method call:
[someObject someMethodThatTakesABlock:^returnType (parameters) {...}];

//5.As a typedef:
typedef returnType (^TypeName)(parameterTypes);
TypeName blockName = ^returnType(parameters) {...};

```

## Chapter 5 Blocks Implementation

> 总结:  
> block只要捕获的是一个对象,那么必须是在block被copy到堆区的时候进行捕获:`1.3`,`1.4`,`1.5`  
> 1.3和1.5的区别在于当`__block`和`__strong`同时修饰的一个对象,`1.5`会先调用`__Block_byref_id_object_copy_131`  
> **对象不一定存在堆区: 只是由于栈区小,堆区在无内存警告时大,一般的对象都在堆区;存在栈区的对象在`{ }`作用域除了之后就销毁了**
 
### 1.Block的实现
		   
#### 1.1 常规的block

> clang -rewrite-objc file_name_of_the_source_code

```objc
int main()
	blk();
```
转换之后

```c
struct __block_impl { 
	void *isa;
	void *FuncPtr;

	//构造函数
		impl.isa = &_NSConcreteStackBlock;//栈block
	}


	unsigned long Block_size;

}
```

#### 1.2 捕获自动变量的block实现

```c
int main() {
		printf(fmt, val);
	}; 
	return 0;
```

```c++
struct __main_block_impl_0 {
	const char *fmt;
		impl.Flags = flags;
};

	int val = __cself->val; 
	printf(fmt, val);

	unsigned long reserved; 
	unsigned long Block_size;

  	return 0; 
 }
```

#### 1.3 捕获__block修饰的栈变量

```objc
__block int val = 10;


```

```c++
struct __Block_byref_val_0 { 
	void *__isa;
	int __flags;

		impl.isa = &_NSConcreteStackBlock;
	}

	//当block被拷贝到堆区时,__block变量也会被拷贝到堆区,block会持有这个__block变量
	//为了保证无论__block变量在栈区或者堆区都能访问的是堆区的__block变量,使用了这种机制
}


		void (*dispose)(struct __main_block_impl_0*);

	//__block修饰的变量转换成了一个结构体
		0,
		sizeof(__Block_byref_val_0), 10
	blk = &__main_block_impl_0(__main_block_func_0, &__main_block_desc_0_DATA, &val, 0x22000000);
}

```
![SamuelChan/20170824163740.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170824163740.png)

#### 1.4 捕获对象的实现(没__block修饰)

```c++
blk_t blk;
	blk = [^(id obj) {
}

blk([[NSObject alloc] init]); 
blk([[NSObject alloc] init]);

//输出
array count = 1
```

底层实现  

```c++
Listing 5–8. Converted source code of Listing 5–7




 } __main_block_desc_0_DATA = {0,sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

}

(*blk->impl.FuncPtr)(blk, [[NSObject alloc] init]); 
(*blk->impl.FuncPtr)(blk, [[NSObject alloc] init]);
```

#### 1.5 捕获__block修饰的对象

```objc
__block id __strong obj = [[NSObject alloc] init];

```

```c++
struct __Block_byref_obj_0 { 
	void *__isa;
	__strong id obj;

/*
  1.跟捕获非__block对象的区别: __Block_byref_id_object_copy_131和__Block_byref_id_object_dispose_131;当obj由__strong修饰时,就调用了__Block_byref_id_object_copy_131;
  2.obj是一个包着[[NSObject alloc] init]的对象,内存管理由__strong修饰,
  3.新增的两个方法用来对[[NSObject alloc] init]进行内存管理
*/

	_Block_object_assign((char*)dst + 40, *(void * *) ((char*)src + 40), 131);

}

	sizeof(__Block_byref_obj_0), 
	__Block_byref_id_object_copy_131, 	
	__Block_byref_id_object_dispose_131, 
	[[NSObject alloc] init]
```

> 接下来讨论的两个问题: 1. Block是如何内存分配? 2.为什么需要__forwarding?

### 2.Block的储存

- _NSConcreteStackBlock   
- _NSConcreteGlobalBlock   
- _NSConcreteMallocBlock

![SamuelChan/20170824164632.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170824164632.png)

#### 2.1 _NSConcreteGlobalBlock

_NSConcreteGlobalBlock:储存在数据区,全局只有一个满足两个条件即是全局Block:  
1. block被定义在全局变量处   
2. 没有捕获任何自动变量

#### 2.2 _NSConcreteStackBlock

除了_NSConcreteGlobalBlock之外其他情况定义的block都是_NSConcreteStackBlock;

#### 2.3 _NSConcreteMallocBlock

![SamuelChan/20170824180051.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170824180051.png)

![SamuelChan/20170824180111.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170824180111.png)

1.在ARC下,大部分情况下面,编译器都会自动copy block到堆区:函数的返回参数

```objc
typedef int (^blk_t)(int);
```

```objc
blk_t func(int rate)
}
```
2.需要手动copy block:block作为方法参数(除了Grand Central Dispatch API,Cocoa框架usingBlock开头的方法名)

```objc
- (id) getBlockArray

//原因:从栈区复制到堆区消耗的性能过大,所以编译器不会将所有block都拷贝到堆区,这种情况下需要手动调用copy

//错误
id obj = getBlockArray();
blk();//栈block销毁,野指针

//正确
- (id) getBlockArray
```

#### 2.4 __block变量的内存分析

![SamuelChan/20170828162555.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170828162555.png)
(1) 当一个Block被拷贝到堆区时,被Block使用到的__block变量会被拷贝到堆区中, 原栈区 __block变量的属性变量 __forwarding将会指向堆区的拷贝后的 __block变量(保证在block内和block外访问的__block都是同一个变量)  
(2) __block被多个Block(拷贝到堆区)引用时, __block(同一个对象)的引用计数+1
![SamuelChan/20170828171220.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170828171220.png)

![SamuelChan/20170828171727.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170828171727.png)

#### 2.5 三种block与copy的关系 

栈block ---copy --- >>> 堆block的四种情况:    
1. Block手动调用了copy  
2. Block作为函数的返回值  
3. Block被__strong修饰  
4. Block作为方法参数(usingBlock,GCD)

![SamuelChan/20170828161255.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20170828161255.png)

### 3.循环引用问题

#### 3.1 问题的发生 

- 直接引用self
- 引用了成员变量

```objc
//测试self
- (void)testCircularRef{
        
    self.blockName = ^int (int a){
       //capturing 'self' strongly in this block is likely to lead to a retain cycle
        NSLog(@"self = %@",self);
        return a;
    };

    self.blockName(19);
}

//测试成员变量
- (void)testCircularRefVar{
    
    testVar = 10;
    
    blk = ^{
       //capturing 'self' strongly in this block is likely to lead to a retain cycle
        NSLog(@"%ld",testVar);
    };
    
    blk();
}
```

#### 3.2 观点

- **如果block中使用了self,但是self没有拥有这个block**:没有循环引用,但是知道block执行完毕,self才会dealloc(最好是不直接使用self,不利于内存管理)
- **weakSelf,strongSelf dance**:weakSelf用来弱引用self,strongSelf保证block执行区间,self不为空;
- **在block中使用self和在block中使用strongSelf的区别:** 前者在在编译时Block捕获到该变量就被强引用了,即就算block不执行,也可能会循环引用;而后者只有在block被执行的时候才会强引用self,否则不会.
 
```objc
    @weakify(self);
    self.blockName = ^ {
        @strongify(self);
        NSLog(@"self = %@",self.testArr);
    };

```

#### 参考资料:  
[@weakify 与 @strongify 的实现](http://www.saitjr.com/ios/ios-libextobjc-1.html)  
[Is the weakSelf/strongSelf dance really necessary when referencing self inside a non-retained completion called from a UIViewController?](https://stackoverflow.com/questions/21113963/is-the-weakself-strongself-dance-really-necessary-when-referencing-self-inside-a?rq=1)