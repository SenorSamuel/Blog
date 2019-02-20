//
//  NSMutableArray+stopException.m
//  DesignPatter_ClassCluster
//
//  Created by 1 on 2019/2/18.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "NSMutableArray+stopException.h"
#import "NSObject+SwizzleHook.h"

@implementation NSMutableArray (stopException)



+(void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"),@selector(addObject:),@selector(hookAddObject:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
    });
}


- (void) hookAddObject:(id)anObject {
    if (anObject) {
        [self hookAddObject:anObject];
    }else{
        NSLog(@"NSMutableArray addObject nil object");
    }
}

- (id)hookObjectAtIndex:(NSUInteger)index{

    if (index <= self.count - 1) {
        return [self hookObjectAtIndex:index];
    }else{
        NSLog(@"NSMutableArray out of index");
        return nil;
    }
}

@end
