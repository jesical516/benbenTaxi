//
//  NearByDriverModel.m
//  benbenTaxi
//
//  Created by 晨松 on 13-7-28.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "NearByDriverModel.h"

@implementation NearByDriverModel

- (NSString*) getNearByDriverInfo {
    return driverInfo;
}

- (void) setNearByDriverInfo : (NSString*) newDriverInfo {
    driverInfo = newDriverInfo;
}

- (void) setStatus : (bool) requestStatus {
    status = requestStatus;
}

- (bool) getStatus {
    return status;
}

@end