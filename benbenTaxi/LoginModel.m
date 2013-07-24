//
//  LoginModel.m
//  benbenTaxi
//
//  Created by 晨松 on 13-7-21.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "LoginModel.h"

@implementation LoginModel
    bool loginStatus;
    NSString* errorInfo;

- (void) setLoginStatus : (bool) status
{
    loginStatus = status;
}
- (void) setErrorInfo : (NSString*) info
{
    errorInfo = info;
}

- (bool) getLoginStatus {
    return loginStatus;
}

- (NSString*) getErrorInfo {
    return errorInfo;
}

@end
