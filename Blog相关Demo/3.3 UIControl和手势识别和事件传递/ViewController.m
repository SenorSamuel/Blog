//
//  ViewController.m
//  3.3 UIControl和手势识别和事件传递
//
//  Created by SamuelChan on 2018/6/25.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}
- (IBAction)tapAction:(id)sender {
    
    NSLog(@"=========> single Tapped");
}

- (IBAction)testBtnClicked {
    NSLog(@"=========> click testbtn");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
