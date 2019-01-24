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

> int *(pfun(int, int)); //指针函数:返回值是一个指针的函数pfun();   

> int (*pfun)(int, int); //函数指针:指向函数的一个指针;


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
> (1) 当一个对象在block中被使用时(`1.3`,`1.4`,`1.5`),如果block没有被copy(栈block或者全局block)的话,那么block不会拥有该对象的ownerShip,只是拷贝了指针引用而已,该对象能否访问与block无关;只有block被copy的时候,block拷贝到了堆区,才会对使用到的对象进行内存管理;一般来说,block如果需要被正确引用('保存一段代码,在适合的时机调用'),在ARC下都避免不了被拷贝到堆区  
> (2) 1.3和1.5的区别在于当`__block`和`__strong`同时修饰的一个对象,`1.5`会先调用`__Block_byref_id_object_copy_131`  
> (3) **对象不一定存在堆区: 只是由于栈区小,堆区在无内存警告时大,一般的对象都在堆区;存在栈区的对象在`{ }`作用域除了之后就销毁了**
 
### 1.Block的实现
		   
#### 1.1 常规的block

> clang -rewrite-objc file_name_of_the_source_code

```objc
int main()
{
	void (^blk)(void) = ^{printf("Block\n");}; 
	blk();
	return 0;
}
```
转换之后

```c
struct __block_impl { 
	void *isa;
	int Flags;
	int Reserved; 
	void *FuncPtr;
};

struct __main_block_impl_0 {
	struct __block_impl impl;
	struct __main_block_desc_0* Desc;
	//构造函数
	__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) { 
		impl.isa = &_NSConcreteStackBlock;//栈block
		impl.Flags = flags;
		impl.FuncPtr = fp;
		Desc = desc; 
	}
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself)
{
	printf("Block\n");
}

static struct __main_block_desc_0
{
	unsigned long reserved; 
	unsigned long Block_size;
} __main_block_desc_0_DATA = { 0,sizeof(struct __main_block_impl_0) };

int main() {
	void (*blk)(void) = (void (*)(void))&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA);

   ((void (*)(struct __block_impl *))((struct __block_impl *)blk)->FuncPtr)((struct __block_impl *)blk);

	return 0; 
}
```

#### 1.2 捕获自动变量的block实现

```c
int main() {
	int dmy = 256;
	int val = 10;
	const char *fmt = "val = %d\n";
	void (^blk)(void) = ^{
		printf(fmt, val);
	}; 
	return 0;
}
```

```c++
struct __main_block_impl_0 {
	struct __block_impl impl;
	struct __main_block_desc_0* Desc; 
	const char *fmt;
	int val;
	__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc,const char *_fmt, int _val, int flags=0) : fmt(_fmt), val(_val) {
		impl.isa = &_NSConcreteStackBlock; 
		impl.Flags = flags;
		impl.FuncPtr = fp;
		Desc = desc;
	} 
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself)
{
	const char *fmt = __cself->fmt; 		
	int val = __cself->val; 
	printf(fmt, val);
}

static struct __main_block_desc_0 { 
	unsigned long reserved; 
	unsigned long Block_size;
} __main_block_desc_0_DATA = { 0,sizeof(struct __main_block_impl_0) };

int main() {
	int dmy = 256;
	int val = 10;
	const char *fmt = "val = %d\n";
	void (*blk)(void) = &__main_block_impl_0(
	__main_block_func_0, &__main_block_desc_0_DATA, fmt, val);
  	return 0; 
 }
```


> 捕获对象时(包括__block变量和局部对象)

|type|Argument|
| --- | --- |
| Object |__block variable|
| BLOCK_FIELD_IS_OBJECT | BLOCK_FIELD_IS_BYREF |

#### 1.3 捕获__block修饰的栈变量

```objc
__block int val = 10;

void (^blk)(void) = ^{val = 1;};

```

```c++
struct __Block_byref_val_0 { 
	void *__isa;
	__Block_byref_val_0 *__forwarding; 
	int __flags;
	int __size;
	int val;
};

struct __main_block_impl_0 {
	struct __block_impl impl;
	struct __main_block_desc_0* Desc;
	__Block_byref_val_0 *val;
	__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc,__Block_byref_val_0 *_val, int flags=0) : val(_val->__forwarding) { 
		impl.isa = &_NSConcreteStackBlock;
		impl.Flags = flags;
		impl.FuncPtr = fp;
		Desc = desc; 
	}
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself)
{
	__Block_byref_val_0 *val = __cself->val;
	//当block被拷贝到堆区时,__block变量也会被拷贝到堆区,block会持有这个__block变量
	//为了保证无论__block变量在栈区或者堆区都能访问的是堆区的__block变量,使用了这种机制
	(val->__forwarding->val) = 1; 
}

static void __main_block_copy_0( struct __main_block_impl_0*dst,struct __main_block_impl_0*src)
{
	_Block_object_assign(&dst->val, src->val, BLOCK_FIELD_IS_BYREF);
}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {
	_Block_object_dispose(src->val, BLOCK_FIELD_IS_BYREF); 
}

static struct __main_block_desc_0 {
	unsigned long reserved;
	unsigned long Block_size;
	void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*); 	void (*dispose)(struct __main_block_impl_0*);

} __main_block_desc_0_DATA = {0,sizeof(struct __main_block_impl_0),__main_block_copy_0, __main_block_dispose_0};

int main()
{
	//__block修饰的变量转换成了一个结构体
	__Block_byref_val_0 val = {
		0,
		&val,
		0, 
		sizeof(__Block_byref_val_0), 10
	};
	
	blk = &__main_block_impl_0(__main_block_func_0, &__main_block_desc_0_DATA, &val, 0x22000000);
	return 0; 
}

```
![SamuelChan/20170824163740.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20170824163740.png)

#### 1.4 捕获对象的实现(没__block修饰)

```c++
blk_t blk;
{
	id array = [[NSMutableArray alloc] init]; 
	blk = [^(id obj) {
		[array addObject:obj];
		NSLog(@"array count = %ld", [array count]); } copy];
}

blk([[NSObject alloc] init]); 
blk([[NSObject alloc] init]);
blk([[NSObject alloc] init]);

//输出
array count = 1
array count = 2
array count = 3
```

底层实现  

```c++
Listing 5–8. Converted source code of Listing 5–7
/* a struct for the Block and some functions */
struct __main_block_impl_0 {
	struct __block_impl impl;
	struct __main_block_desc_0* Desc;
	id __strong array;//如果array是__weak修饰的话,那么这里就是__weak,不是__strong
	__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, id __strong _array, int flags=0) : array(_array) {
	impl.isa = &_NSConcreteStackBlock;
	 impl.Flags = flags;
	impl.FuncPtr = fp;
	Desc = desc;
} };

static void __main_block_func_0(struct __main_block_impl_0 *__cself, id obj)
{
	id __strong array = __cself->array;
	[array addObject:obj];
	NSLog(@"array count = %ld", [array count]);
}

static void __main_block_copy_0(struct __main_block_impl_0 *dst, struct __main_block_impl_0 *src)
{
	_Block_object_assign(&dst->array, src->array,BLOCK_FIELD_IS_OBJECT);//Block持有对象
}

static void __main_block_dispose_0(struct __main_block_impl_0 *src)
{
	_Block_object_dispose(src->array, BLOCK_FIELD_IS_OBJECT);//Block被释放时调用
}

static struct __main_block_desc_0 {
	unsigned long reserved;
	unsigned long Block_size;
	void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*); void (*dispose)(struct __main_block_impl_0*);
 } __main_block_desc_0_DATA = {0,sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

/* Block literal and executing the Block */
blk_t blk;
{
	id __strong array = [[NSMutableArray alloc] init];
	blk = &__main_block_impl_0(__main_block_func_0,&__main_block_desc_0_DATA, array, 0x22000000);
	blk = [blk copy]; 
}

(*blk->impl.FuncPtr)(blk, [[NSObject alloc] init]); 
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
	__Block_byref_obj_0 *__forwarding;
	int __flags;
	int __size;
	void (*__Block_byref_id_object_copy)(void*, void*); void 	(*__Block_byref_id_object_dispose)(void*); 
	__strong id obj;
};

/*
  1.跟捕获非__block对象的区别: __Block_byref_id_object_copy_131和__Block_byref_id_object_dispose_131; 用来对[[NSObject alloc] init]进行内存管理(在__block被销毁时,进行dispose,在初始化时,进行copy.)
  2.obj是一个包着[[NSObject alloc] init]的对象,内存管理由__strong修饰,
  3. 当block被拷贝到对上面时, 还是会调用__main_block_dispose_0和__main_block_copy_0
*/

static void __Block_byref_id_object_copy_131(void *dst, void *src) {
	_Block_object_assign((char*)dst + 40, *(void * *) ((char*)src + 40), 131);
}

static void __Block_byref_id_object_dispose_131(void *src) {
	_Block_object_dispose(*(void * *) ((char*)src + 40), 131); 
}

/* __block variable declaration */
__Block_byref_obj_0 obj = { 0,
	&obj,
	0x2000000, 
	sizeof(__Block_byref_obj_0), 
	__Block_byref_id_object_copy_131, 	
	__Block_byref_id_object_dispose_131, 
	[[NSObject alloc] init]
};
```

> 接下来讨论的两个问题: 1. Block是如何内存分配? 2.为什么需要__forwarding?

### 2.Block的储存

- _NSConcreteStackBlock   
- _NSConcreteGlobalBlock   
- _NSConcreteMallocBlock

![SamuelChan/20170824164632.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20170824164632.png)

#### 2.1 _NSConcreteGlobalBlock

_NSConcreteGlobalBlock:储存在数据区,全局只有一个满足两个条件即是全局Block:  
1. block被定义在全局变量处   
2. 没有捕获任何自动变量

#### 2.2 _NSConcreteStackBlock

除了_NSConcreteGlobalBlock之外其他情况定义的block都是_NSConcreteStackBlock;

#### 2.3 _NSConcreteMallocBlock

![SamuelChan/20170824180051.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20170824180051.png)

![SamuelChan/20170824180111.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20170824180111.png)

1.在ARC下,大部分情况下面,编译器都会自动copy block到堆区:函数的返回参数

```objc
typedef int (^blk_t)(int);
blk_t func(int rate)
{
	return ^(int count){return rate * count;};
}
```

```objc
blk_t func(int rate)
{
	blk_t tmp = &__func_block_impl_0(__func_block_func_0, &__func_block_desc_0_DATA, rate);
	tmp = objc_retainBlock(tmp);//相当于_Block_copy
	return objc_autoreleaseReturnValue(tmp);
}
```
2.需要手动copy block:block作为方法参数(除了Grand Central Dispatch API,Cocoa框架usingBlock开头的方法名)

```objc
- (id) getBlockArray
{
	int val = 10;
	return [[NSArray alloc] initWithObjects: ^{NSLog(@"blk0:%d", val);}, ^{NSLog(@"blk1:%d", val);}, nil];
}

//原因:从栈区复制到堆区消耗的性能过大,所以编译器不会将所有block都拷贝到堆区,这种情况下需要手动调用copy

//错误
id obj = getBlockArray();
typedef void (^blk_t)(void);
blk_t blk = (blk_t)[obj objectAtIndex:0]; 
blk();//栈block销毁,野指针

//正确
- (id) getBlockArray
{
	int val = 10;
	return [[NSArray alloc] initWithObjects: [^{NSLog(@"blk0:%d", val);} copy], [^{NSLog(@"blk1:%d", val);} copy], nil];
}
```

#### 2.4 __block变量的内存分析

![SamuelChan/20170828162555.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20170828162555.png)
(1) 当一个Block被拷贝到堆区时,被Block使用到的__block变量会被拷贝到堆区中, 原栈区 __block变量的属性变量 __forwarding将会指向堆区的拷贝后的 __block变量(保证在block内和block外访问的__block都是同一个变量)  
(2) __block被多个Block(拷贝到堆区)引用时, __block(同一个对象)的引用计数+1
![SamuelChan/20170828171220.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20170828171220.png)

![SamuelChan/20170828171727.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20170828171727.png)

#### 2.5 三种block与copy的关系 

栈block ---copy --- >>> 堆block的四种情况:    
1. Block手动调用了copy  
2. Block作为函数的返回值  
3. Block被__strong修饰  
4. Block作为方法参数(usingBlock,GCD)

![SamuelChan/20170828161255.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20170828161255.png)

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

### Block の 拾遗

![SamuelChan/20180711222625.png](https://samuel-image-hosting.oss-cn-shenzhen.aliyuncs.com/SamuelChan/20180711222625.png)

### 参考资料:  
[@weakify 与 @strongify 的实现](http://www.saitjr.com/ios/ios-libextobjc-1.html)  
[Is the weakSelf/strongSelf dance really necessary when referencing self inside a non-retained completion called from a UIViewController?](https://stackoverflow.com/questions/21113963/is-the-weakself-strongself-dance-really-necessary-when-referencing-self-inside-a?rq=1)
