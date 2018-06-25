//
//  IndexBarTableView.h
//  UITableView重用机制
//
//  Created by SamuelChan on 2018/6/24.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IndexBarTableViewDataSource <NSObject>
// 获取一个tableview的字母索引条数据的方法
- (NSArray <NSString *> *)indexTitlesForIndexTableView:(UITableView *)tableView;

@end

@interface IndexBarTableView : UITableView

@property (nonatomic, weak) id <IndexBarTableViewDataSource> indexedDataSource;

@end
