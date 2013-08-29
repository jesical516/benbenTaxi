//
//  ResponseHandler.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-30.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "ResponseHandler.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation ResponseHandler
DriverResponseModel* responseHandlerModel;


-(void) setDriverResponseModel : (DriverResponseModel*) handlerModel {
    responseHandlerModel = handlerModel;
}

-(void) confirmRequest : (NSString*) requestID {
    NSLog(@"request start");
    NSString* urlPrefix = @"http://42.121.55.211:8081/api/v1/taxi_requests/";
    NSLog(@"Request id is %@", requestID);
    NSString* requestSuffix = [NSString stringWithFormat:@"%@",requestID];
    NSString* urlAddress = [urlPrefix stringByAppendingString:requestSuffix];
    urlAddress = [urlAddress stringByAppendingString:@"/confirm"];
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
    [request setRequestMethod:@"post"];
    [headerDict setValue:cookiesTemp forKey:@"Cookie"];
    [request setRequestHeaders : headerDict];
    
    [ ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES ];
    
    [request setDelegate:self];
    [request startAsynchronous];
    NSLog(@"request is send")
    ;}

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
        [responseHandlerModel setConfirmStatus : FALSE];
        [responseHandlerModel setValue:@"false" forKey:@"confirmState"];
        [responseHandlerModel setValue:baseError forKey:@"confirmResponse"];

    } else {
        NSString* state = [driverResponseDict objectForKey:@"state"];
        NSLog(@"state is %@", state);
        [responseHandlerModel setConfirmStatus : TRUE];
        [responseHandlerModel setValue:state forKey:@"confirmState"];
        NSString *responseDetail = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"response is %@", responseDetail);
        [responseHandlerModel setValue:responseDetail forKey:@"confirmResponse"];
        
    }
}

- (void) requestFailed : (ASIHTTPRequest *)request
{
    [responseHandlerModel setConfirmStatus : FALSE];
    [responseHandlerModel setValue:@"fail" forKey:@"confirmState"];
    [responseHandlerModel setValue:@"" forKey:@"confirmResponse"];
}

@end
