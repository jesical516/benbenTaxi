//
//  LoginModel.h
//  benbenTaxi
//
//  Created by 晨松 on 13-7-21.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginModel : NSObject

- (void) setLoginStatus : (bool) status;
- (void) setErrorInfo : (NSString*) info;
- (bool) getLoginStatus;
- (NSString*) getErrorInfo;
@end
