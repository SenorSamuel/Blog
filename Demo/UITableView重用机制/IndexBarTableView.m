//
//  IndexBarTableView.m
//  UITableView重用机制
//
//  Created by SamuelChan on 2018/6/24.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import "IndexBarTableView.h"
#import "ViewReusablePool.h"

@interface IndexBarTableView()

@property (nonatomic, strong) ViewReusablePool *pool;

@property (nonatomic, strong) UIView *containerView;

@end

@implementation IndexBarTableView

-(void)reloadData {
    
    [super reloadData];
    
    //避免索引条随着table滚动
    [self.superview insertSubview:self.containerView aboveSubview:self];
    
    // 标记所有视图为可重用状态
    [self.pool reset];
    
    // reload字母索引条
    [self reloadIndexedBar];
}

-(void)reloadIndexedBar{
    
    // 获取字母索引条的显示内容
    NSArray <NSString *> *arrayTitles = nil;
    if ([self.indexedDataSource respondsToSelector:@selector(indexTitlesForIndexTableView:)]) {
        arrayTitles = [self.indexedDataSource indexTitlesForIndexTableView:self];
    }
    
    // 判断字母索引条是否为空
    if (!arrayTitles || arrayTitles.count <= 0) {
        [self.containerView setHidden:YES];
        return;
    }
    
    NSUInteger count = arrayTitles.count;
    CGFloat buttonWidth = 60;
    CGFloat buttonHeight = self.frame.size.height / count;
    
    for (int i = 0; i < [arrayTitles count]; i++) {
        NSString *title = [arrayTitles objectAtIndex:i];
        
        // 从重用池当中取一个Button出来
        UIButton *button = (UIButton *)[self.pool dequeueReusableView];
        // 如果没有可重用的Button重新创建一个
        if (button == nil) {
            button = [[UIButton alloc] initWithFrame:CGRectZero];
            button.backgroundColor = [UIColor whiteColor];
            
            // 注册button到重用池当中
            [self.pool addUsingView:button];
            NSLog(@"新创建一个Button");
        }else{
            NSLog(@"Button 重用了");
        }
        
        // 添加button到父视图控件
        [self.containerView addSubview:button];
        [button setTitle:title forState:UIControlStateNormal];
        // 设置button的坐标
        [button setFrame:CGRectMake(0, i * buttonHeight, buttonWidth, buttonHeight)];
    }
    
    [self.containerView setHidden:NO];
    self.containerView.frame = CGRectMake(self.frame.origin.x + self.frame.size.width - buttonWidth, self.frame.origin.y, buttonWidth, self.frame.size.height);
}


#pragma mark - getter,setter
-(ViewReusablePool *)pool{
    if (_pool == nil) {
        _pool = [[ViewReusablePool alloc] init];
    }
    return _pool;
}

-(UIView *)containerView{
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];

    }
    return _containerView;
}


@end
