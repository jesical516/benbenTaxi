//
//  benbenConn.m
//  benbenTaxi
//
//  Created by 晨松 on 13-7-14.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "benbenConn.h"

@implementation benbenConn
    NSString *createPassengerApi = @"";
    NSString *loginApi = @"";
    NSString *getNearbyDriversApiPrefix = @"";
    NSString *sendTaxiRequestApi = @"";
    NSString *confirmTaxiRequestApi = @"";

//这里的这些api，应该都返回json格式，这样调用方可以自己决定如何使用

+(bool) createPassenger : (NSString*) requestStr {
    
}

+(bool) passengerLogin : (NSString*) requestStr {
    
}

+(bool) getNearbyDrivers : (NSString*) requestStr {
    
}

+(bool) sendTaxiRequest : (NSString*) requestStr {
    
}

+(bool) confirmTaxiRequest : (NSString*) requestStr {
    
}

@end


