//
//  DriverResponseManager.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-23.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DriverResponseModel.h"

@interface DriverResponseManager : NSObject 
-(void) setDriverResponseModel : (DriverResponseModel*) newDriverResponseModel;
-(void) getDriverResponse : (NSString*) requestID;


@end