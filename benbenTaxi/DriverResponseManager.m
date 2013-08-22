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

-(void) setDriverResponseModel : (DriverResponseModel*) newDriverResponseModel {
    driverResponseModel = newDriverResponseModel;
}
-(void) getDriverResponse : (NSString*) requestID {
    NSString* urlPrefix = @"http://42.121.55.211:8081/api/v1/taxi_requests/:";
    NSString* urlAddress = [urlPrefix stringByAppendingString:requestID];
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
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    NSDictionary *taxiIDResultDict = [responseData objectFromJSONData];
    NSDictionary *errorDict = [taxiIDResultDict objectForKey:@"errors"];
    if(nil != errorDict) {
        NSArray* keysArray = [errorDict allKeys];
        NSString* firstKey = [keysArray objectAtIndex:0];
        NSArray *baseArray = [errorDict objectForKey:firstKey];
        NSLog(@"base array is %@", baseArray.JSONString);
        NSString* baseError = (NSString*)[baseArray objectAtIndex:0];
    } else {
    }
}

- (void) requestFailed : (ASIHTTPRequest *)request
{
}


@end
