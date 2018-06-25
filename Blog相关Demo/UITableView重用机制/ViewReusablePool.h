//
//  ViewReusablePool.h
//  UITableView重用机制
//
//  Created by SamuelChan on 2018/6/24.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewReusablePool : NSObject

// 从重用池当中取出一个可重用的view
- (UIView *)dequeueReusableView;

// 向重用池当中添加一个视图
- (void)addUsingView:(UIView *)view;

// 重置方法，将当前使用中的视图全部移动到可重用队列当中
- (void)reset;



@end
