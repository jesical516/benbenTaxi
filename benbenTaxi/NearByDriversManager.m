//
//  NearByDriversManager.m
//  benbenTaxi
//
//  Created by 晨松 on 13-7-28.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "NearByDriversManager.h"
#import "NearByDriverModel.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation NearByDriversManager
NearByDriverModel* nearByDriverModel;

-(void) setNearByDriverModel : (NearByDriverModel*) model {
    nearByDriverModel = model;
}

- (void) getNearbyDrivers : (CLLocationCoordinate2D) passengerLocation {
    NSString* requestStr = @"http://42.121.55.211:8081/api/v1/users/nearby_driver?lat=";
    NSString* latitudeStr = [NSString stringWithFormat:@"%f", passengerLocation.latitude];
    NSString* longitudeStr = [NSString stringWithFormat:@"%f", passengerLocation.longitude];
    
    requestStr = [requestStr stringByAppendingString:latitudeStr];
    requestStr = [requestStr stringByAppendingString : @"&lng="];
    requestStr = [requestStr stringByAppendingString : longitudeStr];
    
    NSURL *url = [NSURL URLWithString:requestStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL : url];
    [request setRequestMethod:@"GET"];
    //需要设置cookies
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *cookieStr = [prefs valueForKey:@"cookie"];
    NSData* jsonData = [cookieStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *cookieDict = [jsonData objectFromJSONData];
    NSString *cookieKey = [cookieDict objectForKey:@"token_key"];
    NSString *cookieValue = [cookieDict objectForKey:@"token_value"];
    
    NSLog(@"cookieKey:%@", cookieKey);
    NSLog(@"cookieValue:%@", cookieValue);
    
    NSString* cookiesTemp = [cookieKey stringByAppendingString:@"="];
    cookiesTemp = [cookiesTemp stringByAppendingString:cookieValue];
    NSLog(@"cookiesTemp:%@", cookiesTemp);
    
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
    NSString *str1 = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str1);
    [nearByDriverModel setValue:str1 forKey:@"driverInfo"];
    [nearByDriverModel setStatus:TRUE];
    //[nearByDriverModel setNearByDriverInfo : str1];
}

- (void) requestFailed : (ASIHTTPRequest *)request
{
    NSString* requestError = @"网络不给力，请检查网络设置";
    [nearByDriverModel setValue:requestError forKey:@"driverInfo"];
    [nearByDriverModel setStatus:false];
}

@end
