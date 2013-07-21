//
//  locationModel.m
//  benbenTaxi
//
//  Created by 晨松 on 13-7-21.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "LocationModel.h"

@implementation LocationModel
CLLocationCoordinate2D passengerLocation;
NSString* detailAddress;

- (CLLocationCoordinate2D) getPassengerLocation {
    return passengerLocation;
}

- (NSString*) getDetailAddress {
    return detailAddress;
}

- (void) setPassengerLocation : (CLLocationCoordinate2D) newLocation {
    passengerLocation = newLocation;
}

- (void) setDetailAddress : (NSString*) newDetailAddress {
    detailAddress = newDetailAddress;
}

@end
