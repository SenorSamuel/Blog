//
//  NSObject+SwizzleHook.m
//  DesignPatter_ClassCluster
//
//  Created by 1 on 2019/2/18.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "NSObject+SwizzleHook.h"
#import <objc/runtime.h>

@implementation NSObject (SwizzleHook)

//void swizzleClassMethod(Class cls, SEL originSelector, SEL swizzleSelector){
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Method originalMethod = class_getClassMethod(cls, originSelector);
//        Method swizzledMethod = class_getClassMethod(cls, swizzleSelector);
//
//        Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
//        if (class_addMethod(metacls,
//                            originSelector,
//                            method_getImplementation(swizzledMethod),
//                            method_getTypeEncoding(swizzledMethod)) ) {
//            /* swizzing super class method, added if not exist */
//            class_replaceMethod(metacls,
//                                swizzleSelector,
//                                method_getImplementation(originalMethod),
//                                method_getTypeEncoding(originalMethod));
//
//        } else {
//            /* swizzleMethod maybe belong to super */
//            class_replaceMethod(metacls,
//                                swizzleSelector,
//                                class_replaceMethod(metacls,
//                                                    originSelector,
//                                                    method_getImplementation(swizzledMethod),
//                                                    method_getTypeEncoding(swizzledMethod)),
//                                method_getTypeEncoding(originalMethod));
//        }
//    });
//}

//+ (void)sc_swizzleClassMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector{
//    swizzleClassMethod(self.class, originSelector, swizzleSelector);
//}


void swizzleInstanceMethod(Class cls, SEL originalSelector, SEL swizzledSelector){
    if (!cls) {
        return;
    }
    /* if current class not exist selector, then get super*/
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(cls,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}



@end
