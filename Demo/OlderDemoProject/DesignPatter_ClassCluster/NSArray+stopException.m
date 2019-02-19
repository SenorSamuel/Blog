////
////  NSArray+stopException.m
////  DesignPatter_ClassCluster
////
////  Created by 1 on 2019/2/18.
////  Copyright © 2019 SamuelChan. All rights reserved.
////
//
//#import "NSArray+stopException.h"
//#import "NSObject+SwizzleHook.h"
//
//@implementation NSArray (stopException)
//
//+(void)load {
//    
//    swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
//}
//
//- (id)hookObjectAtIndex:(NSUInteger)index{
//    
//    if (index <= self.count - 1) {
//        return [self hookObjectAtIndex:index];
//    }else{
//        NSLog(@"NSMutableArray out of index");
//        return nil;
//    }
//}
//
//@end
