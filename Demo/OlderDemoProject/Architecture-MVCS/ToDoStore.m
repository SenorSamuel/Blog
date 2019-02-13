//
//  ToDoStore.m
//  Architecture-MVCS
//
//  Created by 1 on 2019/2/13.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "ToDoStore.h"

@interface ToDoStore ()

@property (strong, nonatomic) NSMutableArray *items;


@end

@implementation ToDoStore

+ (instancetype)store{
    
    ToDoStore *store = [[self alloc]init];
    if (store) {
        store.items = [NSMutableArray array];
    }
    return store;
}

- (void)append:(ToDoItem *)item{
    
    [self.items addObject:item];
}

- (void)remove:(ToDoItem *)item{
    
    if ([self.items containsObject:item]) {
        [self.items removeObject:item];
    }
}

- (void)removeAtIndex:(NSInteger )index{
    
    NSParameterAssert(index > (self.items.count - 1));
    
    [self.items removeObjectAtIndex:index];
}

- (NSInteger)count{
    return self.items.count;
}

- (ToDoItem *)itemAtIndex:(NSInteger)index{
    
    NSParameterAssert(index > (self.items.count - 1));
    
    return self.items[index];
}

- (void)diffWithOriginal:(NSArray *)original now:(NSArray *)now{
    
    NSMutableSet *originalSet = [NSMutableSet setWithArray:original];
    NSMutableSet *nowSet      = [NSMutableSet setWithArray:now];
    
    NSInteger idx             = -1;
    ToDoStoreAction action    = -1;
    //只考虑 add/remove 一个 item 的情况
    if ([originalSet isSubsetOfSet:nowSet]) { //add
        
        [nowSet intersectSet:originalSet];
        idx = [now indexOfObject:[nowSet anyObject]];
        
    }else if([nowSet isSubsetOfSet:originalSet]){ //remove

        [originalSet intersectSet:nowSet];
        idx = [original indexOfObject:[originalSet anyObject]];
        
    }else {

    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoItemDidChangedNotification" object:self userInfo:@{@"idx":@(idx),@"action":@(action)}];
}

#pragma mark - getter,setter
-(void)setItems:(NSMutableArray *)items{
    
    id oldValue = _items;
    _items = items;
    if (oldValue) {
        [self diffWithOriginal:oldValue now:_items];
    }
}


//static func diff(original: [ToDoItem], now: [ToDoItem]) -> ChangeBehavior {
//    let originalSet = Set(original)
//    let nowSet = Set(now)
//    
//    if originalSet.isSubset(of: nowSet) { // Appended
//        let added = nowSet.subtracting(originalSet)
//        let indexes = added.compactMap { now.index(of: $0) }
//        return .add(indexes)
//    } else if (nowSet.isSubset(of: originalSet)) { // Removed
//        let removed = originalSet.subtracting(nowSet)
//        let indexes = removed.compactMap { original.index(of: $0) }
//        return .remove(indexes)
//    } else { // Both appended and removed
//        return .reload
//    }
//}
//
//private var items: [ToDoItem] = [] {
//    didSet {
//        let behavior = ToDoStore.diff(original: oldValue, now: items)
//        NotificationCenter.default.post(
//                                        name: .toDoStoreDidChangedNotification,
//                                        object: self,
//                                        typedUserInfo: [.toDoStoreDidChangedChangeBehaviorKey: behavior]
//                                        )
//    }
//}




@end
