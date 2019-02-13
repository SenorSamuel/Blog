//
//  ViewController.m
//  Architecture-MVCS
//
//  Created by 1 on 2019/2/13.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "ViewController.h"
#import "ToDoItem.h"
#import "ToDoStore.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

//@property (strong, nonatomic) NSMutableArray<ToDoItem *> *items;

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (nonatomic,strong) ToDoStore *store;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //view configure
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.addButton addTarget:self action:@selector(addButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todoItemsDidChange:) name:@"TodoItemDidChangedNotification" object:nil];
}


- (void)updateAddButtonState{
    
    [self.addButton setEnabled: (self.store.count <= 10) ];

}

- (void)updateTableViewWithIdx:(NSInteger)idx action:(ToDoStoreAction)action {
    
    switch (action) {
        case ToDoStoreActionAdd:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
        case ToDoStoreActionRemove:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
        case ToDoStoreActionReload:
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

#pragma mark - Notification
- (void)todoItemsDidChange:(NSNotification *)notice{
    
    NSDictionary *userInfoDict = notice.userInfo;
    
    NSInteger idx = [userInfoDict[@"idx"] integerValue];
    ToDoStoreAction action = [userInfoDict[@"action"] integerValue];
    
    if (userInfoDict) {
        //1.更新 tableView
        [self updateTableViewWithIdx:idx action:action];
        //2.更新按钮
        [self updateAddButtonState];
    }
}

#pragma mark - Action
- (void)addButtonDidClick{

    NSInteger count = self.store.count;
    
    ToDoItem *item = [[ToDoItem alloc]initWithTitle:[NSString stringWithFormat:@"ToDo item %ld",count + 1]];
    [self.store append:item];
    
//    [self.tableView reloadData];
//
//    if (self.items.count >= 10) {
//        [self.addButton setEnabled:NO];
//    }
}


#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.store.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    cell.textLabel.text = [self.store itemAtIndex:indexPath.row].title;
    
    return cell;
}

#pragma mark - UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // 用户确认删除，从 `items` 中移除该事项
        [self.store removeAtIndex:indexPath.row];
//        // 从 table view 中移除对应行
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        // 维护 addButton 状态
//        if (self.items.count < 10) {
//            [self.addButton setEnabled:YES];
//        }
        
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

//-(NSMutableArray<ToDoItem *> *)items{
//    if (_items == nil) {
//        _items = [NSMutableArray array];
//    }
//    return _items;
//}

-(ToDoStore *)store{
    if (_store == nil) {
        _store = [ToDoStore store];
    }
    return _store;
}

@end
