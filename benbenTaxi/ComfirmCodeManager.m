//
//  ComfirmCodeManager.m
//  benbenTaxi
//
//  Created by 晨松 on 13-9-8.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "ComfirmCodeManager.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "ComfirmCodeModel.h"

@implementation ComfirmCodeManager
ComfirmCodeModel* comfirmCodeModel;

- (void) getConfirmCode : (NSString*) phoneNum
{
    NSMutableDictionary *postInfoJobj = [NSMutableDictionary dictionary];
    NSMutableDictionary *userInfoJobj = [NSMutableDictionary dictionary];
    [userInfoJobj setObject : phoneNum forKey:@"mobile"];
    
    [postInfoJobj setObject : userInfoJobj forKey:@"register_verification"];
    NSString *strPostInfo = [postInfoJobj JSONString];
    
    NSURL *url = [NSURL URLWithString:@"http://yangquan.benbentaxi.com:80/api/v1/register_verifications"];
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
        [comfirmCodeModel setStatus:true];
        [comfirmCodeModel setValue:baseError forKey:@"response"];
    } else {
        [comfirmCodeModel setStatus:true];
        [comfirmCodeModel setValue:str1 forKey:@"response"];
    }
}

- (void) requestFailed : (ASIHTTPRequest *)request
{
    NSString* requestError = @"发送失败，请重试";
    [comfirmCodeModel setStatus:false];
    [comfirmCodeModel setValue:requestError forKey : @"response"];
}
-(void) setComfirmCodeModel : (ComfirmCodeModel*) comfirmCodeModel
{
    comfirmCodeModel = comfirmCodeModel;
}

@end