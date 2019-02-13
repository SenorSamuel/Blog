//
//  ToDoStore.h
//  Architecture-MVCS
//
//  Created by 1 on 2019/2/13.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToDoItem.h"

typedef NS_ENUM(NSUInteger, ToDoStoreAction) {
    ToDoStoreActionAdd,
    ToDoStoreActionRemove,
    ToDoStoreActionReload,
};

@interface ToDoStore : NSObject

+ (instancetype)store;

- (void)append:(ToDoItem *)item;

- (void)remove:(ToDoItem *)item;

- (NSInteger)count;

- (ToDoItem *)itemAtIndex:(NSInteger)index;

@end

