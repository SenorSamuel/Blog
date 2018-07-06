//
//  ViewController.m
//  消息转发和动态添加方法
//
//  Created by SamuelChan on 2018/7/6.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import "ViewController.h"
#import "SCObject.h"
#import "DelegateProxy.h"
#import "TableViewDelegate.h"

@interface ViewController ()

@property (nonatomic, strong) DelegateProxy *proxy;

@property (nonatomic, strong) TableViewDelegate *tableDelegate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //动态方法解析
    SCObject *obj = [SCObject new];
    [obj test];
    
    //多重代理
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor redColor];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 1000);
    _proxy = [DelegateProxy new];
    _tableDelegate = [TableViewDelegate new];
    [_proxy setDelegateTargets:@[self,_tableDelegate]];
    scrollView.delegate = _proxy;
    [self.view addSubview:scrollView];
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%s", __FUNCTION__);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
