//
//  ViewController.m
//  DesignPatternDemo
//
//  Created by 陈晓明 on 2019/2/12.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "ViewController.h"

//简单工厂模式
#import "SimpleFactory(简单工厂模式)/PhoneSimpleFactory.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //简单工厂模式
    [self testSimpleFactory];
}

- (void)testSimpleFactory {
    id<PhoneProtocol> phone = [PhoneSimpleFactory createPhoneWithType:0];
    NSLog(@"phone = %@",phone);
    phone = [PhoneSimpleFactory createPhoneWithType:1];
    NSLog(@"phone = %@",phone);
}


@end
