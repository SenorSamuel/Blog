//
//  ViewController.m
//  DesignPatter_ClassCluster
//
//  Created by 1 on 2019/2/18.
//  Copyright © 2019 SamuelChan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

//https://gist.github.com/Catfish-Man/bc4a9987d4d7219043afdf8ee536beb2
//https://blog.sunnyxx.com/2014/12/18/class-cluster/

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self testClassCluster];
    
    [self makeArrayMoreSafer];
}

- (void)testClassCluster {
    //    id obj1 = [NSArray alloc]; // __NSPlacehodlerArray *
    //    id obj2 = [NSMutableArray alloc];  // __NSPlacehodlerArray *
    //    id obj3 = [obj1 init];  // __NSArrayI *
    //    id obj4 = [obj2 init];  // __NSArrayM *
    
#pragma mark Array
#pragma mark - __NSArray0 : a singleton empty immutable NSArray, makes @[] and [NSArray array] very efficient
    id obj__NSArray0_array     = [NSArray array];
    id obj__NSArray0_array_2   = [[NSArray alloc]init];
    id obj__NSArray0_literal   = @[];
    NSLog(@"\n\nobj__NSArray0_array = %p \nobj__NSArray0_array_2 = %p \nobj__NSArray0_literal = %p",obj__NSArray0_array,obj__NSArray0_array_2,obj__NSArray0_literal);
    printf("\n");
    
#pragma mark - __NSArrayI : an immutable NSArray that stores its contents inline. The most common NSArray type.
    id obj__NSArrayI_instanceMethod = [[NSArray alloc]initWithObjects:@"1",@"1", nil];
    id obj__NSArrayI_literal = @[@"1",@"1"];
    NSLog(@"\n\nobj__NSArrayI_instanceMethod = %p %@ \nobj__NSArrayI_literal = %p %@",obj__NSArrayI_instanceMethod,[obj__NSArrayI_instanceMethod class],obj__NSArrayI_literal,[obj__NSArrayI_literal class]);
    printf("\n");
    
#pragma mark - __NSSingleObjectArrayI : an immutable NSArray that stores a single object inline. Fits in 16 bytes where a regular __NSArrayI would need 24 since it stores the count.
    id obj__NSSingleObjectArrayI_instanceMethod = [[NSArray alloc]initWithObjects:@"1", nil];
    id obj__NSSingleObjectArrayI_literal = @[@"1"];
    NSLog(@"\n\nobj__NSSingleObjectArrayI_instanceMethod = %@ \nobj__NSSingleObjectArrayI_literal = %@",[obj__NSSingleObjectArrayI_instanceMethod class],[obj__NSSingleObjectArrayI_literal class]);
    printf("\n");
    
#pragma mark - __NSArrayM : a mutable NSArray backed by an out of line array-deque
    id obj__NSArrayM_array     = [NSMutableArray array];
    id obj__NSArrayM_array_2   = [[NSMutableArray alloc]initWithObjects:@"1",@"2", nil];
    NSLog(@"\n\nobj__NSArrayM_array = %p  %@ \nobj__NSArrayM_array_2 = %p  %@",obj__NSArrayM_array,[obj__NSArrayM_array class],obj__NSArrayM_array_2,[obj__NSArrayM_array_2 class]);
    printf("\n");
    
#pragma mark - __NSFrozenArrayM - an immutable NSArray sharing its storage with an NSMutableArray that it was -copy'd from (will do a real copy if the original array is mutated)
    //没有找到如何触发
    
#pragma mark -
#pragma mark -
#pragma mark NSDictionary
    
#pragma mark - __NSDictionary0 : a singleton empty immutable NSDictionary. Makes @{} and [NSDictionary dictionary] very efficient.
    id obj__NSDictionary0_array     = [NSDictionary dictionary];
    id obj__NSDictionary0_array_2   = [[NSDictionary alloc]init];
    id obj__NSDictionary0_literal   = @{};
    NSLog(@"\n\nobj__NSDictionary0_array = %p %@ \nobj__NSDictionary0_array_2 = %p %@ \nobj__NSDictionary0_literal = %p %@",obj__NSDictionary0_array,[obj__NSDictionary0_array class],obj__NSDictionary0_array_2,[obj__NSDictionary0_array_2 class],obj__NSDictionary0_literal,[obj__NSDictionary0_literal class]);
    printf("\n");
    
#pragma mark - __NSSingleEntryDictionaryI : an immutable NSDictionary that stores one key-object pair. Avoids having to do any hashing. Useful for things like APIs that take options as a dictionary argument.
    id obj__NSSingleEntryDictionaryI_instanceMethod = [[NSDictionary alloc]initWithObjectsAndKeys:@"value",@"key", nil];//dictionaryWithObjectsAndKeys不行
    id obj__NSSingleEntryDictionaryI_literal = @{@"key":@"value"};
    NSLog(@"\n\nobj__NSSingleEntryDictionaryI_instanceMethod = %@ \nobj__NSSingleEntryDictionaryI_literal = %@",[obj__NSSingleEntryDictionaryI_instanceMethod class],[obj__NSSingleEntryDictionaryI_literal class]);
    printf("\n");
    
#pragma mark - __NSDictionaryI : an immutable NSDictionary backed by an inline linear-probed hash table.
    id obj__NSDictionaryI_instanceMethod = [[NSDictionary alloc]initWithObjectsAndKeys:@"value",@"key",@"value2",@"key2", nil];
    id obj__NSDictionaryI_literal = @{@"key":@"value",
                                      @"key2":@"value2"
                                      };
    NSLog(@"\n\nobj__NSDictionaryI_instanceMethod = %p %@ \nobj__NSDictionaryI_literal = %p %@",obj__NSDictionaryI_instanceMethod,[obj__NSDictionaryI_instanceMethod class],obj__NSDictionaryI_literal,[obj__NSDictionaryI_literal class]);
    printf("\n");
    
#pragma mark - __NSDictionaryM : an immutable NSDictionary sharing its storage with an __NSDictionaryM that it was -copy'd from (usual CoW behavior)
    id obj__NSDictionaryM_dictionary     = [NSMutableDictionary dictionary];
    id obj__NSDictionaryM_dictionary2   = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"value",@"key",@"value2",@"key2", nil];
    NSLog(@"\n\nobj__NSDictionaryM_dictionary = %p  %@ \nobj__NSDictionaryM_dictionary2 = %p  %@",obj__NSDictionaryM_dictionary,[obj__NSDictionaryM_dictionary class],obj__NSDictionaryM_dictionary2,[obj__NSDictionaryM_dictionary2 class]);
    printf("\n");
    
#pragma mark - __NSFrozenDictionaryM : an immutable NSDictionary sharing its storage with an __NSDictionaryM that it was -copy'd from (usual CoW behavior)
    id obj__NSFrozenDictionaryM = [obj__NSDictionaryM_dictionary copy];
    NSLog(@"\n\nobj__NSFrozenDictionaryM = %p  %@ \n",obj__NSFrozenDictionaryM,[obj__NSFrozenDictionaryM class]);
    printf("\n");
    
    
#pragma mark -
#pragma mark -
#pragma mark String
    
#pragma mark - _NSCFString a CFStringRef or CFMutableStringRef. This is the most common type of string object currently. - May have 8 bit (ASCII) or 16 bit (UTF-16) backing store
    id obj_NSCFString = [NSString string];//__NSCFConstantString *    @""
    obj_NSCFString = [NSString stringWithFormat:@"%@",@"a"];//NSTaggedPointerString *    @"a"
    obj_NSCFString = [NSString stringWithFormat:@"%@",@"ssssssssssss"];//__NSCFString *    @"ssssssssssss"
    obj_NSCFString = [[NSString alloc]initWithString:@"a"];//__NSCFConstantString *    @"a"
    obj_NSCFString = @""; //__NSCFConstantString *    @""    0x00000001002282a8
    obj_NSCFString = @"a";//__NSCFConstantString *    @"a"    0x0000000100228288
    obj_NSCFString = @"abc";//__NSCFConstantString *    @"abc"    0x00000001002282c8

    
}

#pragma mark - 设计一个保护NSMutableArray防止越界的方案
/**
 请你设计一个方案，能够针对NSMutabledArray的容易crash的方法增加保护，如objectAtIndex、addObject等
 这道题考察的点有
 - 越界判断
 - 传参校验
 - Class Clusters(类簇)：直接针对NSMutabledArray做Method Swizzling是没用的
 - Method Swizzling实战：具体实现、触发时机、方法交换时的校验等
 */
- (void)makeArrayMoreSafer {
    
    NSMutableArray *obj__NSArrayM = [NSMutableArray array];
    [obj__NSArrayM addObject:@"1"];
    [obj__NSArrayM addObject:@"2"];
    
    //objectAtIndex
    [obj__NSArrayM objectAtIndex:3];
    
    //addObject
    [obj__NSArrayM addObject:nil];
}

@end
