//
//  TableViewDelegate.m
//  消息转发和动态添加方法
//
//  Created by SamuelChan on 2018/7/6.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import "TableViewDelegate.h"
@interface TableViewDelegate()<UIScrollViewDelegate>

@end
@implementation TableViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%s", __FUNCTION__);
}

@end
