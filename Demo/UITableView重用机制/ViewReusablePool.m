//
//  ViewReusablePool.m
//  UITableView重用机制
//
//  Created by SamuelChan on 2018/6/24.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import "ViewReusablePool.h"

@interface ViewReusablePool()

// 等待使用的队列
@property (nonatomic, strong) NSMutableSet *waitUsedQueue;
// 使用中的队列
@property (nonatomic, strong) NSMutableSet *usingQueue;

@end

@implementation ViewReusablePool

-(instancetype)init {
    if (self = [super init]) {
        _waitUsedQueue = [NSMutableSet set];
        _usingQueue    = [NSMutableSet set];
    }
    return self;
}

// 从重用池当中取出一个可重用的view
- (UIView *)dequeueReusableView{
    
    UIView *view = [_waitUsedQueue anyObject];
    
    if (!view) {
        return nil;
    }else {
        [_waitUsedQueue removeObject:view];
        [_usingQueue addObject:view];
        return view;
    }
}

// 向重用池当中添加一个视图
- (void)addUsingView:(UIView *)view{
    
    if (!view) {
        return;
    }
    
    [_usingQueue addObject:view];
}

// 重置方法，将当前使用中的视图全部移动到可重用队列当中
- (void)reset {
    
    UIView *anyView = nil;
    while ((anyView = [_usingQueue anyObject])) {
        // 从使用中队列移除
        [_usingQueue removeObject:anyView];
        // 加入等待使用的队列
        [_waitUsedQueue addObject:anyView];
    }
}

@end
