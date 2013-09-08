//
//  DriverResponseManager.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-23.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "DriverResponseManager.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation DriverResponseManager

DriverResponseModel* driverResponseModel;

-(void) setDriverResponseModel : (DriverResponseModel*) newDriverResponseModel {
    driverResponseModel = newDriverResponseModel;
}

-(void) getDriverResponse : (NSString*) requestID {
    NSLog(@"request start");
    NSString* urlPrefix = @"http://yangquan.benbentaxi.com:80/api/v1/taxi_requests/";
    NSLog(@"Request id is %@", requestID);
    NSString* requestSuffix = [NSString stringWithFormat:@"%@",requestID]; 
    NSString* urlAddress = [urlPrefix stringByAppendingString:requestSuffix];
    NSLog(@"URL is %@", urlAddress);
    NSURL *url = [NSURL URLWithString:urlAddress];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL : url];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *cookieStr = [prefs valueForKey:@"cookie"];
    NSData* jsonData = [cookieStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *cookieDict = [jsonData objectFromJSONData];
    NSString *cookieKey = [cookieDict objectForKey:@"token_key"];
    NSString *cookieValue = [cookieDict objectForKey:@"token_value"];
    NSString* cookiesTemp = [cookieKey stringByAppendingString:@"="];
    cookiesTemp = [cookiesTemp stringByAppendingString:cookieValue];
    NSMutableDictionary * headerDict = [[NSMutableDictionary alloc]init];
    [request setRequestMethod:@"GET"];
    [headerDict setValue:cookiesTemp forKey:@"Cookie"];
    [request setRequestHeaders : headerDict];
    
    [ ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES ];
    
    [request setDelegate:self];
    [request startAsynchronous];
    [request setTimeOutSeconds:5];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    NSDictionary *driverResponseDict = [responseData objectFromJSONData];
    NSDictionary *errorDict = [driverResponseDict objectForKey:@"errors"];
    if(nil != errorDict) {
        NSArray* keysArray = [errorDict allKeys];
        NSString* firstKey = [keysArray objectAtIndex:0];
        NSArray *baseArray = [errorDict objectForKey:firstKey];
        NSLog(@"base array is %@", baseArray.JSONString);
        NSString* baseError = (NSString*)[baseArray objectAtIndex:0];
        [driverResponseModel setDriverResponseStatus : FALSE];
        [driverResponseModel setValue:@"false" forKey:@"requestStatus"];
        [driverResponseModel setValue:baseError forKey:@"driverResponseDetail"];
    } else {
        NSString* state = [driverResponseDict objectForKey:@"state"];
        NSLog(@"state is %@", state);
        [driverResponseModel setDriverResponseStatus : TRUE];
        [driverResponseModel setValue:state forKey:@"requestStatus"];
        NSLog(@"here state is %@", [driverResponseModel valueForKey:@"requestStatus"]);
        NSString *responseDetail = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        [driverResponseModel setValue:responseDetail forKey:@"driverResponseDetail"];
        
    }
}

- (void) requestFailed : (ASIHTTPRequest *)request
{
    [driverResponseModel setDriverResponseStatus : FALSE];
    [driverResponseModel setValue:@"fail" forKey:@"requestStatus"];
    [driverResponseModel setValue:@"" forKey:@"driverResponseDetail"];
    
}


@end
