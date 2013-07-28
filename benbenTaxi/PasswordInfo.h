//
//  PasswordInfo.h
//  benbenTaxi
//
//  Created by 晨松 on 13-7-28.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordInfo : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
