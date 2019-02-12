//
//  ViewController.m
//  Network-NSJSONSerialization
//
//  Created by 1 on 2019/2/12.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,strong) NSData *dataWithNoParam;
@property (nonatomic,strong) NSData *dataWithWritingPrettyPrinted;
@property (nonatomic,strong) NSData *dataWithWritingSortedKeys;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self basicNSJSONSerializationUsage];
    
    [self jsonObjectToData];
    
    [self dataToJsonObject];
    
}

#pragma mark - NSJSONSerialization的基本使用
- (void)basicNSJSONSerializationUsage{
    
    NSDictionary *dict = @{@"age":@(16)};
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
        if (data) {
            NSLog(@"data = %@",data);
        }
        
        id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (obj) {
            NSLog(@"obj = %@",obj);
        }
    }
    
    dict = @{@"age":@"16"};
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
        if (data) {
            NSLog(@"data = %@",data);
        }
        
        id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (obj) {
            NSLog(@"obj = %@",obj);
        }
    }
}

#pragma mark - jsonObject → data
- (void)jsonObjectToData{
    
    NSDictionary *dict = @{
                           @"name":@"Samuel",
                           @"age":@(18),
                           @"hobbit":@[@"basketball",@"esports"],
                           @"dota2":@{
                                   @"level":@(20),
                                   @"nickName":@"Samuel"
                                   }
                           };
    
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        //1.不带参数的打印
        _dataWithNoParam = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
        NSLog(@"str_dataWithNoParam = %@",[[NSString alloc]initWithData:_dataWithNoParam encoding:NSUTF8StringEncoding]);
        
//        str_dataWithNoParam = {"age":18,"hobbit":["basketball","esports"],"dota2":{"level":20,"nickName":"Samuel"},"name":"Samuel"}
        
        //2.NSJSONWritingPrettyPrinted = (1UL << 0),
        _dataWithWritingPrettyPrinted = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"str_dataWithWritingPrettyPrinted = %@",[[NSString alloc]initWithData:_dataWithWritingPrettyPrinted encoding:NSUTF8StringEncoding]);
        
//        str_dataWithWritingPrettyPrinted = {
//            "age" : 18,
//            "hobbit" : [
//                        "basketball",
//                        "esports"
//                        ],
//            "dota2" : {
//                "level" : 20,
//                "nickName" : "Samuel"
//            },
//            "name" : "Samuel"
//        }
        
        //3.NSJSONWritingSortedKeys API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)) = (1UL << 1)
        _dataWithWritingSortedKeys = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingSortedKeys error:nil];
        NSLog(@"str_dataWithWritingSortedKeys = %@",[[NSString alloc]initWithData:_dataWithWritingSortedKeys encoding:NSUTF8StringEncoding]);
        
//        str_dataWithWritingSortedKeys = {"age":18,"dota2":{"level":20,"nickName":"Samuel"},"hobbit":["basketball","esports"],"name":"Samuel"}
    }
}

- (void)dataToJsonObject{
    
    //不考虑NSJsonReadingOptions
    //1.不带参数的打印
    id obj1 = [NSJSONSerialization JSONObjectWithData:_dataWithNoParam options:kNilOptions error:nil];
    NSLog(@"obj_dataWithNoParam = %@",obj1);
    //2.NSJSONWritingPrettyPrinted = (1UL << 0),
    id obj2 = [NSJSONSerialization JSONObjectWithData:_dataWithWritingPrettyPrinted options:kNilOptions error:nil];
    NSLog(@"_dataWithWritingPrettyPrinted = %@",obj2);
    //3.NSJSONWritingSortedKeys API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)) = (1UL << 1)
    id obj3 = [NSJSONSerialization JSONObjectWithData:_dataWithWritingSortedKeys options:kNilOptions error:nil];
    NSLog(@"_dataWithWritingSortedKeys = %@",obj3);
    
    //===========================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    //NSJSONReadingMutableContainers: NSDictionary 和 NSArray 都是mutable的
    id obj4 = [NSJSONSerialization JSONObjectWithData:_dataWithNoParam options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"obj_dataWithNoParam_NSJSONReadingMutableContainers = %@",obj4);
    
    //NSJSONReadingMutableLeaves: NSString类型的 value 会变成 mutable
    id obj5 = [NSJSONSerialization JSONObjectWithData:_dataWithNoParam options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"obj_dataWithNoParam_NSJSONReadingMutableLeaves = %@",obj5);
    
    //NSJSONReadingAllowFragments:https://stackoverflow.com/questions/16961025/nsjsonserialization-nsjsonreadingallowfragments-reading
    NSData *fragmentData = [@"\"Samuel\"" dataUsingEncoding:NSUTF8StringEncoding];
    id obj6 = [NSJSONSerialization JSONObjectWithData:fragmentData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"obj_dataWithNoParam_NSJSONReadingAllowFragments = %@",obj6);

}

@end
