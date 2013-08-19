//
//  CustomWindow.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-11.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "CustomWindow.h"

@implementation CustomWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)sendEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
    }
    [super sendEvent:event];
}

@end
