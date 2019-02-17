//
//  PhoneSimpleFactory.m
//  DesignPatternDemo
//
//  Created by 陈晓明 on 2019/2/10.
//  Copyright © 2019 陈晓明. All rights reserved.
//

#import "PhoneSimpleFactory.h"
#import "Phone.h"
@implementation PhoneSimpleFactory

+(id<PhoneProtocol>)createPhoneWithType:(NSInteger)type{
    
    id<PhoneProtocol> phone = nil;
    
    if (type == 0) {
        phone = [iPhone new];
    }else if(type == 1){
        phone = [AndroidPhone new];
    }
    
    return phone;
}

@end
