//
//  TaxiRequestModel.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-18.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "TaxiRequestModel.h"

@implementation TaxiRequestModel

- (bool) getTaxiRequestStatus {
    return taxiRequestStatus;
}
- (void) setTaxiRequestStatus : (bool) newStatus {
    taxiRequestStatus = newStatus;
}


@end