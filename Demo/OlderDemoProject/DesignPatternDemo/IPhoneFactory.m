//
//  IPhoneFactory.m
//  DesignPatternDemo
//
//  Created by 陈晓明 on 2019/2/17.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "IPhoneFactory.h"
#import "Phone.h"
//抽象工厂
#import "AppleTV.h"

@implementation IPhoneFactory

+(id<PhoneProtocol>)makePhone{

    return [iPhone new];
}

//抽象工厂
+(id<TVProtocol>)makeTV{
    return [AppleTV new];
}

@end
