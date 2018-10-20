//
//  ViewController.m
//  UITableView重用机制
//
//  Created by SamuelChan on 2018/6/24.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import "ViewController.h"
#import "IndexBarTableView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,IndexBarTableViewDataSource>

@property (nonatomic, strong) UIButton *reloadDataBtn;

@property (nonatomic, strong) IndexBarTableView *tableView;

@property (nonatomic, strong) NSMutableArray *arrModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //重置的reloadDataBtn
    self.reloadDataBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    self.reloadDataBtn.backgroundColor = [UIColor redColor];
    [self.reloadDataBtn setTitle:@"reloadTable" forState:UIControlStateNormal];
    [self.reloadDataBtn addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.reloadDataBtn];
    
    //tableView
    self.tableView = [[IndexBarTableView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.indexedDataSource = self;
    [self.view addSubview:self.tableView];
    
    // 数据源
    self.arrModel = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        [self.arrModel addObject:@(i+1)];
    }
}

#pragma mark - @protocol IndexBarTableViewDataSource
// 获取一个tableview的字母索引条数据的方法
- (NSArray <NSString *> *)indexTitlesForIndexTableView:(UITableView *)tableView {
    //奇数次调用返回6个字母，偶数次调用返回11个
    static BOOL change = NO;
    
    if (change) {
        change = NO;
        return @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K"];
    }
    else{
        change = YES;
        return @[@"A",@"B",@"C",@"D",@"E",@"F"];
    }
}


#pragma mark - @protocolUITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"reuseId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //如果重用池当中没有可重用的cell，那么创建一个cell
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    // 文案设置
    cell.textLabel.text = [[self.arrModel objectAtIndex:indexPath.row] stringValue];
    
    //返回一个cell
    return cell;
}

#pragma mark - @protocol UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}


//刷新
-(void)doAction:(UIButton *)reloadDataBtn{
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
