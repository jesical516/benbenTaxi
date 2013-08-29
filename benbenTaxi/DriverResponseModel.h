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
    NSString* requestStatus;
    bool driverResponseStatus;
    bool confirmStatus;
    NSString* confirmResponse;
    NSString* confirmState;
}

- (bool) getDriverResponseStatus;
- (void) setDriverResponseStatus : (bool) newResponseStatus;

- (bool) getConfirmStatus;
- (void) setConfirmStatus : (bool) newConfirmStatus;


@end
