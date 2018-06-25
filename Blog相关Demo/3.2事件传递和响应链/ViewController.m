//
//  ViewController.m
//  3.2事件传递和响应链
//
//  Created by SamuelChan on 2018/6/24.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import "ViewController.h"
#import "CustomBtn.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *cornerButton = [[CustomBtn alloc] initWithFrame:CGRectMake(100, 100, 120, 120)];
    cornerButton.backgroundColor = [UIColor blueColor];
    [cornerButton addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cornerButton];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)doAction:(id)sender{
    NSLog(@"click");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
