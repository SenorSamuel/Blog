//
//  ViewController.m
//  应用评价
//
//  Created by SamuelChan on 2017/6/15.
//  Copyright © 2017年 SamuelChan. All rights reserved.
//

#import "ViewController.h"
#import <StoreKit/StoreKit.h>
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,SKStoreProductViewControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSources;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title                = @"应用评价";
    
    self.tableView            = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.view addSubview:self.tableView];
}

#pragma mark - private method
#pragma mark 1.弹出alertView跳转到app store
-(void)showRatingAlertView{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"程序猿奋力出新版" message:@"打滚儿求好评" delegate:self cancelButtonTitle:@"残忍拒绝" otherButtonTitles:@"好评(跳App store)",@"吐槽(跳App store)",nil];
    
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
        case 2:
            [self jumpToAppStore];
            break;
        default:
            break;
    }
}

/** 跳转到app store */
-(void)jumpToAppStore{
    //支持直接跳转到 AppStore 的评论编辑页
    //通过在项目 URL 查询参数的最后加上 action=write-review 就可以跳转到 AppStore 并自动模态打开评论编辑页面。在此之前我们只能跳转到评论页。
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1014844521&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8&action=write-review"];
    
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
}


#pragma mark 2.当前页面Modal出一个应用评分页面的控制器
- (void)inAppSKStoreProductViewController{
    
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc]init];
    storeProductVC.delegate = self;
    
    [storeProductVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:@"1014844521"} completionBlock:^(BOOL result, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        } else {
            NSLog(@"加载完成");
            [self presentViewController:storeProductVC animated:YES completion:^{
                NSLog(@"界面弹出完成");
            }];
        }
    }];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  3.弹出一个只有评分的框 这里只是为了demo效果放在点击回调中
-(void)inAppSKStoreReviewController{

    [SKStoreReviewController requestReview];
}

#pragma mark 4.我的方案

-(void)myPractice{
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.3) {
        
        [self inAppSKStoreReviewController];
        
    }else{
//自定义弹出规则比如iRate,
//        [[iRate shareInstance] logEvent:NO]
    }
}

#pragma mark - @protocol UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSources[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    cell.textLabel.text = self.dataSources[indexPath.section][indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return @"iOS10.3之前";
    }else if(section == 1) {
        return @"iOS10.3之后";
    }else {
        return @"Practice";
    }
}


#pragma mark @protocol UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
     
        [self showRatingAlertView];
        
    }else if (indexPath.section == 0 && indexPath.row == 1){
        
        [self inAppSKStoreProductViewController];
        
    }else if (indexPath.section == 1 && indexPath.row == 0){
        
        [self inAppSKStoreReviewController];
    }else if (indexPath.section == 2 && indexPath.row == 0){
        [self myPractice];
    }
}

#pragma mark - getter
-(NSArray *)dataSources{
    if (_dataSources == nil) {
        _dataSources = [NSArray arrayWithObjects:@[@"弹出alertView跳转到app store",@"当前页面Modal出一个应用评分页面的控制器"],@[@"弹出一个只有评分的框"],@[@"我的方案"], nil];
    }
    return _dataSources;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
