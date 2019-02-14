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

@synthesize items = _items;

+ (instancetype)store{
    
    ToDoStore *store = [[self alloc]init];

    return store;
}

- (void)append:(ToDoItem *)item{

    [[self mutableArrayValueForKey:@"items"] addObject:item];
}

- (void)remove:(ToDoItem *)item{
    
    if ([self.items containsObject:item]) {
        [[self mutableArrayValueForKey:@"items"] removeObject:item];
    }
}

- (void)removeAtIndex:(NSInteger )index{
    
    NSParameterAssert(index <= (self.items.count - 1));

    [[self mutableArrayValueForKey:@"items"] removeObjectAtIndex:index];

}

- (NSInteger)count{
    return self.items.count;
}

- (ToDoItem *)itemAtIndex:(NSInteger)index{
    
    NSParameterAssert(index <= (self.items.count - 1));
    
    return self.items[index];
}


#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSInteger kind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    NSInteger index = [[change objectForKey:NSKeyValueChangeIndexesKey] firstIndex];
    
    if (kind == NSKeyValueChangeInsertion) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoItemDidChangedNotification" object:self userInfo:@{@"idx":@(index),@"action":@(ToDoStoreActionAdd)}];

    }else if(kind == NSKeyValueChangeRemoval){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoItemDidChangedNotification" object:self userInfo:@{@"idx":@(index),@"action":@(ToDoStoreActionRemove)}];
        
    }else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoItemDidChangedNotification" object:self userInfo:@{@"idx":@(NSNotFound),@"action":@(ToDoStoreActionReload)}];
    }
}



#pragma mark - getter,setter

-(NSMutableArray *)items{
    
    if (!_items) {
        _items = [NSMutableArray array];
        [self addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
    return _items;
}

-(void)dealloc{
    
    [self removeObserver:self forKeyPath:@"items"];
}





@end
