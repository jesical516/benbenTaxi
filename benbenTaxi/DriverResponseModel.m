//
//  DriverResponseModel.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-23.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "DriverResponseModel.h"

@implementation DriverResponseModel


- (bool) getDriverResponseStatus {
    return driverResponseStatus;
}
- (void) setDriverResponseStatus : (bool) newResponseStatus {
    driverResponseStatus = newResponseStatus;
}

@end
