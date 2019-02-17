//
//  FactoryPatternProtocol.h
//  DesignPatternDemo
//
//  Created by 陈晓明 on 2019/2/17.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneProtocol.h"

//抽象工厂
#import "TVProtocol.h"

@protocol FactoryPatternProtocol <NSObject>

+(id<PhoneProtocol>)makePhone;

//抽象工厂
+(id<TVProtocol>)makeTV;

@end
