//
//  ViewController.m
//  Architecture-MVCS
//
//  Created by 1 on 2019/2/13.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "ViewController.h"
#import "ToDoItem.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<ToDoItem *> *items;

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //view configure
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.addButton addTarget:self action:@selector(addButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - Action
- (void)addButtonDidClick{

    NSInteger count = self.items.count;
    
    ToDoItem *item = [[ToDoItem alloc]initWithTitle:[NSString stringWithFormat:@"ToDo item %ld",count + 1]];
    [self.items addObject:item];
    
    [self.tableView reloadData];
    
    if (self.items.count >= 10) {
        [self.addButton setEnabled:NO];
    }
    
}


#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    cell.textLabel.text = self.items[indexPath.row].title;
    
    return cell;
}

#pragma mark - UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // 用户确认删除，从 `items` 中移除该事项
        [self.items removeObjectAtIndex:indexPath.row];
        // 从 table view 中移除对应行
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        // 维护 addButton 状态
        if (self.items.count < 10) {
            [self.addButton setEnabled:YES];
        }
        
        completionHandler(YES);
    }];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
}


#pragma mark - getter,setter
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

-(NSMutableArray<ToDoItem *> *)items{
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

@end
