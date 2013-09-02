//
//  historyRequestManager.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-31.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "historyRequestManager.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"

@implementation historyRequestManager

historyRequestModel* historyModel;

- (void) getHistoryRequest {
    NSString* urlAddress = @"http://42.121.55.211:8081/api/v1/taxi_requests";
    NSURL *url = [NSURL URLWithString : urlAddress];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL : url];
    [request setRequestMethod:@"GET"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *cookieStr = [prefs valueForKey:@"cookie"];
    NSData* jsonData = [cookieStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *cookieDict = [jsonData objectFromJSONData];
    NSString *cookieKey = [cookieDict objectForKey:@"token_key"];
    NSString *cookieValue = [cookieDict objectForKey:@"token_value"];
    NSString* cookiesTemp = [cookieKey stringByAppendingString:@"="];
    cookiesTemp = [cookiesTemp stringByAppendingString:cookieValue];
    NSMutableDictionary * headerDict = [[NSMutableDictionary alloc]init];
    [headerDict setValue:cookiesTemp forKey:@"Cookie"];
    [request setRequestHeaders : headerDict];
    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
    [request setDelegate:self];
    [request startAsynchronous];
    NSLog(@"end");
}

- (void) setModel : (historyRequestModel*) newModel {
    historyModel = newModel;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    NSString *historyRequestResult = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",historyRequestResult);
    [historyModel setStatus:TRUE];
    [historyModel setValue: historyRequestResult forKey:@"historyRequestDetails"];
}

- (void) requestFailed : (ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    NSString *historyRequestResult = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",historyRequestResult);
    [historyModel setStatus:FALSE];
    [historyModel setValue: @"" forKey:@"historyRequestDetails"];
}

@end
