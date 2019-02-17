//
//  AndroidFactory.m
//  DesignPatternDemo
//
//  Created by 陈晓明 on 2019/2/17.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "AndroidFactory.h"
#import "Phone.h"

//抽象工厂
#import "XiaomiTV.h"

@implementation AndroidFactory

+ (id<PhoneProtocol>)makePhone {
    return [AndroidPhone new];
}

//抽象工厂
+ (id<TVProtocol>)makeTV {
    return [XiaomiTV new];
}

@end
