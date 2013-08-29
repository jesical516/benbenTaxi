//
//  ResponseHandler.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-30.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DriverResponseModel.h"

@interface ResponseHandler : NSObject

-(void) setDriverResponseModel : (DriverResponseModel*) newDriverResponseModel;

-(void) confirmRequest : (NSString*) requestID;

@end
