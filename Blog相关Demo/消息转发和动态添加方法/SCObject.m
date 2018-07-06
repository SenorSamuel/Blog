//
//  SCObject.m
//  消息转发和动态添加方法
//
//  Created by SamuelChan on 2018/7/6.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import "SCObject.h"
#import <objc/runtime.h>
@interface MObject : NSObject

-(void)test;


@end

@implementation MObject

-(void)test{
    NSLog(@"%s", __FUNCTION__);
}

@end


@implementation SCObject

void test_imp (void){
    
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
    
    NSLog(@"%s", __FUNCTION__);
}

@end
