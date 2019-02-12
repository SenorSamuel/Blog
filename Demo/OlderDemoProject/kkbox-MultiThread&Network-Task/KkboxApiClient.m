//
//  KkboxApiClient.m
//  kkbox-MultiThread&Network-Task
//
//  Created by 陈晓明 on 2019/2/11.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "KkboxApiClient.h"

@interface KkboxApiClient ()

@property (nonatomic,strong) NSURLSession *session;

@end

@implementation KkboxApiClient


+(instancetype)shared{
    
    static KkboxApiClient *kkboxApiClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kkboxApiClient = [[KkboxApiClient alloc]init];
        kkboxApiClient.session = [NSURLSession sharedSession];
    });
    return kkboxApiClient;
}

- (void)fetchGetResponseWithCallback:(void(^)(NSDictionary *, NSError *))callback {
    
    NSURL *url = [NSURL URLWithString:@"https://httpbin.org/get"];
    
    NSURLSessionTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (callback) {
            //data → json
            NSError *serializationError;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
            if (serializationError) {
                callback(nil,serializationError);
                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                callback(jsonObject,nil);
            });
        }
    }];
    
    [task resume];
}

- (void)postCustomerName:(NSString *)name callback:(void(^)(NSDictionary *, NSError *))callback {
    
    NSParameterAssert(name);
    
    NSURL *url = [NSURL URLWithString:@"https://httpbin.org/post"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    mutableRequest.HTTPMethod = @"POST";
    mutableRequest.HTTPBody = [[NSString stringWithFormat:@"custname=%@",name] dataUsingEncoding:NSUTF8StringEncoding];

    NSURLSessionTask *task = [self.session dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        if (callback) {
            //data → json
            NSError *serializationError;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
            if (serializationError) {
                callback(nil,serializationError);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(jsonObject,nil);
            });
        }
    }];
    
    [task resume];
}

- (void)fetchImageWithCallback:(void(^)(UIImage *, NSError *))callback{
    
    NSURL *url = [NSURL URLWithString:@"https://httpbin.org/image/png"];
    
    NSURLSessionTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (callback) {
            //data → image
            UIImage *image = [UIImage imageWithData:data];
            if (!image) {
                NSError *error = [NSError errorWithDomain:@"http://httpbin.org/image/png" code:-666666 userInfo:@{NSLocalizedDescriptionKey:@"图片下载错误"}];
                callback(nil,error);
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(image,nil);
            });
        }
    }];
    
    [task resume];

}


@end
