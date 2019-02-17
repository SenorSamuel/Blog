//
//  PhoneSimpleFactory.h
//  DesignPatternDemo
//
//  Created by 陈晓明 on 2019/2/10.
//  Copyright © 2019 陈晓明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneProtocol.h"

@interface PhoneSimpleFactory : NSObject

+(id<PhoneProtocol>)createPhoneWithType:(NSInteger)type;

@end

