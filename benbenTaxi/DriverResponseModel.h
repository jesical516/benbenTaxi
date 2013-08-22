//
//  DriverResponseModel.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-23.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverResponseModel : NSObject {
    NSString* driverResponseDetail;
    bool driverResponseStatus;
}

- (bool) getDriverResponseStatus;
- (void) setDriverResponseStatus : (bool) newResponseStatus;

@end
