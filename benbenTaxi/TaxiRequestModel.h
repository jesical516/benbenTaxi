//
//  TaxiRequestModel.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-18.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaxiRequestModel : NSObject {
    bool taxiRequestStatus;
    NSString* request;
}

- (bool) getTaxiRequestStatus;
- (void) setTaxiRequestStatus : (bool) newStatus;

@end