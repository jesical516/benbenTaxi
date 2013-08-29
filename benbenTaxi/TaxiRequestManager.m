//
//  TaxiRequestManager.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-18.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "TaxiRequestManager.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation TaxiRequestManager

NSString* TAXI_REQUEST_API = @"http://42.121.55.211:8081/api/v1/taxi_requests";
-(void) setTaxiRequestModel : (TaxiRequestModel*) newTaxiRequestModel {
    taxiRequestModel = newTaxiRequestModel;
    
}

-(void) sendTaxiRequest : (NSString*) postData {
    NSURL *url = [NSURL URLWithString:TAXI_REQUEST_API];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL : url];
    [request setRequestMethod:@"POST"];
    
    //需要设置cookies
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *cookieStr = [prefs valueForKey:@"cookie"];
    NSData* jsonData = [cookieStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *cookieDict = [jsonData objectFromJSONData];
    NSString *cookieKey = [cookieDict objectForKey:@"token_key"];
    NSString *cookieValue = [cookieDict objectForKey:@"token_value"];
    NSString* cookiesTemp = [cookieKey stringByAppendingString:@"="];
    cookiesTemp = [cookiesTemp stringByAppendingString:cookieValue];
    NSMutableDictionary * headerDict = [[NSMutableDictionary alloc]init];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    [headerDict setValue:@"application/json" forKey:@"Content-Type"];
    [headerDict setValue:cookiesTemp forKey:@"Cookie"];
    [request setRequestHeaders : headerDict];
    
    [ ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES ];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    NSString *advertisingResult = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"result is %@", advertisingResult);
    
    NSDictionary *taxiIDResultDict = [responseData objectFromJSONData];
    NSDictionary *errorDict = [taxiIDResultDict objectForKey:@"errors"];
    if(nil != errorDict) {
        NSArray* keysArray = [errorDict allKeys];
        NSString* firstKey = [keysArray objectAtIndex:0];
        NSArray *baseArray = [errorDict objectForKey:firstKey];
        NSLog(@"base array is %@", baseArray.JSONString);
        NSString* baseError = (NSString*)[baseArray objectAtIndex:0];
        [taxiRequestModel setTaxiRequestStatus:FALSE];
        [taxiRequestModel setValue:baseError forKey:@"request"];
    } else {
        [taxiRequestModel setTaxiRequestStatus:TRUE];
        NSString *requestID = [taxiIDResultDict objectForKey:@"id"];
        [taxiRequestModel setValue:requestID forKey:@"request"];
    }

}

- (void) requestFailed : (ASIHTTPRequest *)request
{
    [taxiRequestModel setTaxiRequestStatus:FALSE];
    [taxiRequestModel setValue: @"" forKey:@"request"];
}


@end
