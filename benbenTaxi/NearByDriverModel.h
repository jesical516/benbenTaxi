//
//  NearByDriverModel.h
//  benbenTaxi
//
//  Created by 晨松 on 13-7-28.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NearByDriverModel : NSObject {
    NSString* driverInfo;
    bool status;
}

- (NSString*) getNearByDriverInfo;
- (void) setNearByDriverInfo : (NSString*) newDriverInfo;
- (void) setStatus : (bool) requestStatus;
- (bool) getStatus;

@end