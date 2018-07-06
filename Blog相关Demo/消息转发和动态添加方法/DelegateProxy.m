//
//  DelegateProxy.m
//  消息转发和动态添加方法
//
//  Created by SamuelChan on 2018/7/6.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import "DelegateProxy.h"

@interface DelegateProxy()

@property (nonatomic, strong) NSPointerArray *weakRefTargets;

@end

@implementation DelegateProxy

-(void)setDelegateTargets:(NSArray*)delegateTargets {
    
    self.weakRefTargets = [NSPointerArray weakObjectsPointerArray];
    for(id delegate in delegateTargets) {
        [self.weakRefTargets addPointer:(__bridge void*)delegate];
    }
}

-(BOOL)respondsToSelector:(SEL)aSelector {
    
    if([super respondsToSelector:aSelector]){
        return YES;
    }
    
    for(id target in self.weakRefTargets){
        if([target respondsToSelector:aSelector]){
            return YES;
        }
    }
    return NO;
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector {
    
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if(!sig) {
        for(id target in self.weakRefTargets) {
            if((sig = [target methodSignatureForSelector:aSelector])){
                break;
            }
        }
    }
    return sig;
}

//转发方法调用给所有delegate
-(void)forwardInvocation:(NSInvocation*)anInvocation {
    for(id target in self.weakRefTargets){
        if([target respondsToSelector:anInvocation.selector]){
            [anInvocation invokeWithTarget:target];
        }
    }
}


@end
