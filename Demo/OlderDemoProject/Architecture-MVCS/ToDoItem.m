//
//  ToDoItem.m
//  Architecture-MVCS
//
//  Created by 1 on 2019/2/13.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "ToDoItem.h"


@implementation ToDoItem

-(instancetype)initWithTitle:(NSString *)title{
    
    if (self = [super init]) {
        _title = title;
    }
    return self;
}

@end
