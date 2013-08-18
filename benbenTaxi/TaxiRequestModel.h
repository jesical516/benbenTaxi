//
//  TaxiRequestModel.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-18.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaxiRequestModel : NSObject {
    bool status;
    NSString* request;
}

- (bool) getStatus;
- (void) setStatus : (bool) newStatus;

@end