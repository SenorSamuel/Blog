//
//  KkboxApiClient.h
//  kkbox-MultiThread&Network-Task
//
//  Created by 陈晓明 on 2019/2/11.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KkboxApiClient : NSObject

+(instancetype)shared;

- (void)fetchGetResponseWithCallback:(void(^)(NSDictionary *, NSError *))callback;

- (void)postCustomerName:(NSString *)name callback:(void(^)(NSDictionary *, NSError *))callback;

- (void)fetchImageWithCallback:(void(^)(UIImage *, NSError *))callback;

@end

