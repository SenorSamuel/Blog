//
//  ViewController.m
//  DesignPatternDemo
//
//  Created by 陈晓明 on 2019/2/12.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "ViewController.h"

//简单工厂模式
#import "PhoneSimpleFactory.h"
//工厂模式
#import "IPhoneFactory.h"
#import "AndroidFactory.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //简单工厂模式
    [self testSimpleFactory];
    
    //工厂模式
    [self testFactoryPattern];
    
    //抽象工厂模式
    [self testAbstractFactoryPattern];
}

#pragma mark - 简单工厂模式
- (void)testSimpleFactory {
    id<PhoneProtocol> phone = [PhoneSimpleFactory createPhoneWithType:0];
    NSLog(@"phone = %@",phone);
    phone = [PhoneSimpleFactory createPhoneWithType:1];
    NSLog(@"phone = %@",phone);
}

#pragma mark - 工厂模式
- (void)testFactoryPattern {

    id<PhoneProtocol> phone = [IPhoneFactory makePhone];
    NSLog(@"phone = %@",phone);
    phone = [AndroidFactory makePhone];
    NSLog(@"phone = %@",phone);
}

#pragma mark - 抽象工厂模式
- (void)testAbstractFactoryPattern{
    
    //苹果工厂
    id<PhoneProtocol> phone = [IPhoneFactory makePhone];
    id<TVProtocol> tv       = [IPhoneFactory makeTV];
    NSLog(@"phone = %@,tv = %@",phone,tv);
    //Android工厂
    phone = [AndroidFactory makePhone];
    tv       = [AndroidFactory makeTV];
    NSLog(@"phone = %@,tv = %@",phone,tv);
}


@end
