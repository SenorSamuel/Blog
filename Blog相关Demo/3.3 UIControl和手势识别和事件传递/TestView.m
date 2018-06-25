//
//  TestView.m
//  3.3 UIControl和手势识别和事件传递
//
//  Created by SamuelChan on 2018/6/25.
//  Copyright © 2018年 SamuelChan. All rights reserved.
//

#import "TestView.h"

@implementation TestView

//test view
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"=========> test view touchs Began");
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"=========> test view touchs Moved");
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"=========> test view touchs Ended");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"=========> test view touchs Cancelled");
}



@end
