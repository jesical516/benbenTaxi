//
//  benbenTaxiLoginManager.m
//  benbenTaxi
//
//  Created by 晨松 on 13-7-23.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "benbenTaxiLoginManager.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "LoginModel.h"

@implementation benbenTaxiLoginManager
LoginModel* model;

- (void) newAcountProcess : (NSString*) phoneNum : (NSString*) password : (NSString*) verifyCode
{
    NSLog(@"phone is %@", phoneNum);
    NSLog(@"password is %@", password);
    
    NSMutableDictionary *postInfoJobj = [NSMutableDictionary dictionary];
    NSMutableDictionary *userInfoJobj = [NSMutableDictionary dictionary];
    [userInfoJobj setObject : phoneNum forKey:@"mobile"];
    [userInfoJobj setObject : password forKey:@"password"];
    [userInfoJobj setObject : password forKey:@"password_confirmation"];
    [userInfoJobj setObject : verifyCode forKey:@"verify_code"];
    
    [postInfoJobj setObject : userInfoJobj forKey:@"user"];
    NSString *strPostInfo = [postInfoJobj JSONString];
    
    NSLog(@"post info is %@", strPostInfo);
    
    NSURL *url = [NSURL URLWithString:@"http://yangquan.benbentaxi.com:80/api/v1/users/create_passenger"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL : url];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[strPostInfo dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary * headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setValue:@"application/json" forKey:@"Content-Type"];
    [request setRequestHeaders : headerDict];
    [ ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES ];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void) loginProcess : (NSString*) phoneNum : (NSString*) password
{
    NSMutableDictionary *postInfoJobj = [NSMutableDictionary dictionary];
    NSMutableDictionary *userInfoJobj = [NSMutableDictionary dictionary];
    [userInfoJobj setObject : phoneNum forKey:@"mobile"];
    [userInfoJobj setObject : password forKey:@"password"];
    [postInfoJobj setObject : userInfoJobj forKey:@"session"];
    NSString *strPostInfo = [postInfoJobj JSONString];
    
    NSURL *url = [NSURL URLWithString:@"http://yangquan.benbentaxi.com:80/api/v1/sessions/passenger_signin"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL : url];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[strPostInfo dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary * headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setValue:@"application/json" forKey:@"Content-Type"];
    [request setRequestHeaders : headerDict];
    [ ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES ];
    
    [request setDelegate:self];
    [request startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    NSString *str1 = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str1);

    NSDictionary *loginResult = [responseData objectFromJSONData];
    NSDictionary *errorDict = [loginResult objectForKey:@"errors"];
    if(nil != errorDict) {
        NSArray* keysArray = [errorDict allKeys];
        NSString* firstKey = [keysArray objectAtIndex:0];
        NSArray *baseArray = [errorDict objectForKey:firstKey];
        NSLog(@"base array is %@", baseArray.JSONString);
        NSString* baseError = (NSString*)[baseArray objectAtIndex:0];
        [model setLoginStatus:false];
        [model setErrorInfo:baseError];
    } else {
        NSString* responseStr = @"";
        [model setLoginStatus:true];
        [model setSessionInfo : str1];
        NSLog(@"session is %@", [model getSessionInfo]);
        [model setErrorInfo:responseStr];
    }
}

- (void) requestFailed : (ASIHTTPRequest *)request
{
    NSString* requestError = @"网络不给力，稍后再试";
    [model setLoginStatus:false];
    [model setErrorInfo:requestError];
}
-(void) setLoginModel : (LoginModel*) loginModel
{
    model = loginModel;
}
@end
