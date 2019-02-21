//
//  ViewController.m
//  multiThread
//
//  Created by SamuelChan on 2017/9/26.
//  Copyright © 2017年 chenxiaoming. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign) NSInteger tickets;//票数

@property (nonatomic, strong) NSOperationQueue *queue;


@property (nonatomic, strong) dispatch_queue_t photoQueue;

@property (nonatomic, strong) NSMutableArray *photoList;

@property (atomic, assign)    int       intA;
@property (atomic, strong) NSString*                 stringA;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    //1.测试耗时
    //[self headFirstDemo];

//    //2.1 多线程资源掠夺
//    [self testTitleSold];
//    //2.2 值类型Property
//    [self testThreadInsecureDemo1];
//    //2.3 指针Property指向的内存区域
//    [self testThreadInsecureDemo2];
    //2.4 解决线程不安全
//    [self testThreadInsecureSolutionDemo];
    
/** GCD */
//    1.串行队列 同步执行
//    [self serialSync];
//    2.串行队列 异步执行
//    [self serialAsync];
//    3.并行队列,异步执行
//    [self concurrentAsnc];
//    4.并行队列,同步执行
//    [self concurrentSync];
//    5.gcdBarrierTest
//    [self gcdBarrierTest];
//    [self barrierExample01];
//    [self testOrder];
    
/** NSOperation */
//1.NSInvocationOperation
//    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperation:) object:@{@"msg": @"invocationOperation 基本使用", @"parameter": @"呵呵"}];
//    [invocationOperation start];

//2.加入队列
//    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperation:) object:@{@"msg": @"invocationOperation 基本使用", @"parameter": @"呵呵"}];
//    //创建队列
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    //将操作添加到队列中
//    [queue addOperation:invocationOperation];
//3.NSBlockOperation
//    [self blockOperation];
//4.操作完成的回调
//    [self operationComCallBack];
//5.NSOperation最大并发数
//    [self maxConcurrentCountTest];
    
}

- (void)headFirstDemo {
    /*
     1. 循环的速度很快
     2. 循环消耗 CPU 资源
     3. 栈区操作很快
     4. 常量操作很快
     5. 堆区操作速度不快
     6. I / O 操作速度慢
     */
    // 获取时间
    NSTimeInterval start = CACurrentMediaTime();
    
    for (NSInteger i = 0; i < 100000; i++) {
        NSInteger num = i;
        NSString *text = @"hello";
        NSString *name = [NSString stringWithFormat:@"%@ - %zd", text, num];
        // 输出
        NSLog(@"%@", name);
    }
    
    // 结束时间 - 开始时间
    NSLog(@"over %f", CACurrentMediaTime() - start);
}

#pragma mark - 线程不安全定义:同时对变量进行读写
#pragma mark 卖票
- (void)testTitleSold{
        self.tickets = 100;
        [NSThread detachNewThreadSelector:@selector(saleTitle) toTarget:self withObject:nil];
        [NSThread detachNewThreadSelector:@selector(saleTitle) toTarget:self withObject:nil];
        [NSThread detachNewThreadSelector:@selector(saleTitle) toTarget:self withObject:nil];
}

- (void)saleTitle{
    
    NSTimeInterval start = CACurrentMediaTime();
    
    while (YES) {
        
        // 模拟延时
        [NSThread sleepForTimeInterval:0.5];
        
        // @synchronized(self){
            if (self.tickets > 0) {
                self.tickets --;
                NSLog(@"卖票成功,剩下%ld张票 %@",self.tickets,[NSThread currentThread]);
            }else{
                NSLog(@"票卖光了 耗时:%f %@", CACurrentMediaTime() - start,[NSThread currentThread]);
                break;
            }
        //}
    }
}

#pragma mark 值类型Property
-(void)testThreadInsecureDemo1{
        //thread A
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (int i = 0; i < 10000; i ++) {
                self.intA = self.intA + 1;
                NSLog(@"Thread A: %d\n", self.intA);
            }
        });
    
        //thread B
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (int i = 0; i < 10000; i ++) {
                self.intA = self.intA + 1;
                NSLog(@"Thread B: %d\n", self.intA);
            }
        });
}

#pragma mark 指针Property指向的内存区域
-(void)testThreadInsecureDemo2{
    //thread A
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 100000; i ++) {
            if (i % 2 == 0) {
                self.stringA = @"a very long string";
            }
            else {
                self.stringA = @"string";
            }
            NSLog(@"Thread A: %@\n", self.stringA);
        }
    });
    
    //thread B
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 100000; i ++) {
            if (self.stringA.length >= 10) {
                NSString* subStr = [self.stringA substringWithRange:NSMakeRange(0, 10)];
            }
            NSLog(@"Thread B: %@\n", self.stringA);
        }
    });
}

#pragma mark 解决线程不安全
- (void)testThreadInsecureSolutionDemo{
    NSLock *lock = [NSLock new];
    //thread A
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 100000; i ++) {
            [lock lock];
            if (i % 2 == 0) {
                self.stringA = @"a very long string";
            }
            else {
                self.stringA = @"string";
            }
            NSLog(@"Thread A: %@\n", self.stringA);
            [lock unlock];
        }
    });
    
    //thread B
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 100000; i ++) {
            [lock lock];
            if (self.stringA.length >= 10) {
                NSString* subStr = [self.stringA substringWithRange:NSMakeRange(0, 10)];
            }
            NSLog(@"Thread B: %@\n", self.stringA);
            [lock unlock];
        }
    });
}

#pragma mark - GCD
/**
 *  串行队列 同步执行
 */

- (void)serialSync {
    // 定义串行队列
    // const char *label: 队列的名称
    // dispatch_queue_attr_t attr: 队列的属性, 并发队列，串行队列
    dispatch_queue_t queue = dispatch_queue_create("serialSync", DISPATCH_QUEUE_SERIAL);
    
    // 同步执行多个任务,同步不会开线程，是在当前线程上面
    dispatch_sync(queue, ^{
        // 创建任务
        NSLog(@"gcd 同步执行 串行任务1 = %@", [NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        // 创建任务
        NSLog(@"gcd 同步执行 串行任务2 = %@", [NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        // 创建任务
        NSLog(@"gcd 同步执行 串行任务3 = %@", [NSThread currentThread]);
    });
}

/**
 *  串行队列 异步执行
 */
- (void)serialAsync {
    // 创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("serialAsync", DISPATCH_QUEUE_SERIAL);
    
    // 异步执行串行队列的任务会开线程,
    for (NSInteger i = 0; i < 20; ++i) {
        dispatch_async(queue, ^{
            // 创建任务
            NSLog(@"gcd 串行任务 异步执行%ld = %@", i, [NSThread currentThread]);
        });
    }
}


/*
 并发队列 异步执行
 */
- (void)concurrentAsnc {
    // 并发队列
    dispatch_queue_t queue = dispatch_queue_create("concurrentAsnc", DISPATCH_QUEUE_CONCURRENT);
    
    
    for (NSInteger i = 0; i < 20; ++i) {
        // 异步执行
        dispatch_async(queue, ^{
            // 任务
            NSLog(@"任务%ld 并行队列 异步执行 线程 = %@",i,[NSThread currentThread]);
        });
    }
}

/*
 并发队列 同步执行
 同步不会开线程，在当前线程 任务只能一个执行完在执行下一个
 */
- (void)concurrentSync {
    // 并发队列
    dispatch_queue_t queue = dispatch_queue_create("concurrentSync", DISPATCH_QUEUE_CONCURRENT);
    
    
    for (NSInteger i = 0; i < 20; ++i) {
        // 同步执行, 不会开启线程,在当前线程执行
        dispatch_sync(queue, ^{
            // 任务
            NSLog(@"任务%ld 并发队列 同步执行 线程 = %@",i,[NSThread currentThread]);
        });
    }
}

#pragma mark dipatch_async_barrier example01

- (void)barrierExample01{
    
    _photoList = [[NSMutableArray alloc] init];
    _photoQueue = dispatch_queue_create("com.samuel.barrier", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 330; ++i) {
        dispatch_async(_photoQueue, ^{
            NSLog(@"下载照片%d", i);
            dispatch_barrier_async(_photoQueue, ^{
                NSLog(@"添加图片 %d,%@", i,[NSThread currentThread]);
                [self.photoList addObject:@(i)];
            });
        });
    }
}

- (void)gcdBarrierTest {
    // 使用自定义并发队列
    dispatch_queue_t queue = dispatch_queue_create("cn.itcast", DISPATCH_QUEUE_CONCURRENT);
    
    int count = 1000;
    
    dispatch_async(queue, ^{
        for (int i = 0; i < count; i++) {}
        NSLog(@"下载图片 A");
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < count; i++) {}
        NSLog(@"下载图片 B");
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < count; i++) {}
        NSLog(@"下载图片 C");
    });
    
    dispatch_barrier_async(queue, ^{
        for (int i = 0; i < count; i++) {}
        NSLog(@"播放音乐");
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < count; i++) {}
        NSLog(@"下载视频 E");
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < count; i++) {}
        NSLog(@"下载视频 F");
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < count; i++) {}
        NSLog(@"下载视频 G");
    });
}

-(void)testOrder {
    NSLog(@"1");
    dispatch_queue_t global_queue = dispatch_get_global_queue(0, 0);
    //将任务提交,并且等待任务完成
    dispatch_sync(global_queue, ^{
        NSLog(@"2");
        //并行队列中的任务,在同一个线程是可以并发执行的:一个线程在多个任务中切换
        dispatch_sync(global_queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

#pragma mark - NSOperation
- (void)invocationOperation:(NSString *)msg {
    NSLog(@"thread = %@, msg = %@", [NSThread currentThread], msg);
}


- (void)blockOperation {
    // 1. 创建操作
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation1, thread = %@", [NSThread currentThread]);
    }];
    
    // 一个 NSBlockOperation 操作可以添加多个 block 任务
    for (NSInteger i = 2; i < 100; ++i) {
        [blockOperation addExecutionBlock:^{
            NSLog(@"blockOperation%ld, thread = %@",i, [NSThread currentThread]);
        }];
    }
    
    // 2. 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 3. 将任务添加到队列中
    [queue addOperation:blockOperation];
}

- (void)operationComCallBack {
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"operation2 thread = %@", [NSThread currentThread]);
    }];
    
    // operation2 操作完成的回调
    [operation2 setCompletionBlock:^{
        NSLog(@"operation2 thread = %@", [NSThread currentThread]);
    }];
    [queue addOperation:operation2];
}

- (void)maxConcurrentCountTest{
    
    _queue = [NSOperationQueue new];
    _queue.maxConcurrentOperationCount = 2;
    
    for (NSInteger i = 0; i < 20; ++i) {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            [NSThread sleepForTimeInterval:2];
            NSLog(@"op = %ld,当前线程 = %@",i,[NSThread currentThread]);
        }];
        [_queue addOperation:op];
    }
}


-(IBAction)suspendBtnClick:(id)sender{
    if (!_queue.suspended) {
        // operationCount 包含正在执行的 操作
        NSLog(@"挂起队列, 当前队列中还有%zd个任务", _queue.operationCount);
        // 挂起任务,没有执行的操作才会暂停,已经在执行的操作会继续执行
        _queue.suspended = YES;
    }
}

-(IBAction)cancelAllOperationClick:(id)sender{
    
    NSLog(@"取消之前有%ld个任务", _queue.operationCount);
    [_queue cancelAllOperations];
    NSLog(@"取消之后有%ld个任务", _queue.operationCount);
}

-(IBAction)continueBtnClick:(id)sender{
    if (_queue.suspended) {
        // operationCount 包含正在执行的 操作
        NSLog(@"继续队列, 当前队列中还有%zd个任务", _queue.operationCount);
        //继续任务,没有执行的操作才会继续
        _queue.suspended = NO;
    }
}



@end
