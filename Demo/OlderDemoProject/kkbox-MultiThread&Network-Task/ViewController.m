//
//  ViewController.m
//  kkbox-MultiThread&Network-Task
//
//  Created by 陈晓明 on 2019/2/11.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "ViewController.h"
#import "KkboxApiClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [[KkboxApiClient shared] fetchGetResponseWithCallback:^(NSDictionary *dict, NSError *error) {
        NSLog(@"thread = %@,dict = %@,error = %@",[NSThread currentThread],dict,error);
    }];
    
    [[KkboxApiClient shared] postCustomerName:@"Samuel" callback:^(NSDictionary *dict, NSError *error) {
        NSLog(@"thread = %@,dict = %@,error = %@",[NSThread currentThread],dict,error);
    }];
    
    [[KkboxApiClient shared] fetchImageWithCallback:^(UIImage *image, NSError *error) {
        NSLog(@"thread = %@,image = %@,error = %@",[NSThread currentThread],image,error);
    }];
}


@end
