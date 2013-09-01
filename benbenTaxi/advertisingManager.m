//
//  AdvertisingManager.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-4.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "AdvertisingManager.h"
#import "AdvertisingModel.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation AdvertisingManager

AdvertisingModel* model;
NSString* api = @"http://42.121.55.211:8081/api/v1/advertisements";

- (void) setAdvertisingModel : (AdvertisingModel*) newModel {
    model = newModel;
}

- (void) updateAdvertisingInfo {
    NSURL *url = [NSURL URLWithString:api];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL : url];
    [request setRequestMethod:@"GET"];
    //需要设置cookies
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *cookieStr = [prefs valueForKey:@"cookie"];
    NSLog(@"cookie is %@", cookieStr);
    NSData* jsonData = [cookieStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *cookieDict = [jsonData objectFromJSONData];
    NSString *cookieKey = [cookieDict objectForKey:@"token_key"];
    NSString *cookieValue = [cookieDict objectForKey:@"token_value"];
    NSString* cookiesTemp = [cookieKey stringByAppendingString:@"="];
    cookiesTemp = [cookiesTemp stringByAppendingString:cookieValue];
    NSMutableDictionary * headerDict = [[NSMutableDictionary alloc]init];
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
    NSData *data = [advertisingResult dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arr = (NSArray *)[data mutableObjectFromJSONData];
    NSString* advertisingInfo = @"";
    for(int i=0;i<arr.count;i++)
    {
        NSDictionary *advertisingItem = [arr objectAtIndex:i];
        NSString *adInfo = [advertisingItem objectForKey:@"content"];
        if ([advertisingInfo isEqualToString:@""]) {
            advertisingInfo = adInfo;
        } else {
            advertisingInfo = [ advertisingInfo stringByAppendingString: @" "];
            advertisingInfo = [ advertisingInfo stringByAppendingString: adInfo];
            
        }
    }

    NSLog(@"%@",advertisingResult);
    [model setStatus:TRUE];
    [model setValue: advertisingInfo forKey:@"advertisingInfo"];
}

- (void) requestFailed : (ASIHTTPRequest *)request
{
    [model setStatus:FALSE];
    [model setValue: @"" forKey:@"advertisingInfo"];
}

@end