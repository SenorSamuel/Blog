//
//  ToDoItem.h
//  Architecture-MVCS
//
//  Created by 1 on 2019/2/13.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject

@property (copy, nonatomic) NSString *title;

-(instancetype)initWithTitle:(NSString *)title;

@end

