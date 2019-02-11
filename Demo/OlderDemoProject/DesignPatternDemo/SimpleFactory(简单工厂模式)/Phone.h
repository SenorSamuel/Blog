//
//  Phone.h
//  DesignPatternDemo
//
//  Created by 陈晓明 on 2019/2/10.
//  Copyright © 2019 陈晓明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface iPhone : NSObject<PhoneProtocol>

@end



@interface AndroidPhone : NSObject<PhoneProtocol>

@end

NS_ASSUME_NONNULL_END
