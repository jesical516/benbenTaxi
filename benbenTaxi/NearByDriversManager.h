//
//  NearByDriversManager.h
//  benbenTaxi
//
//  Created by 晨松 on 13-7-28.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearByDriverModel.h"
#import "BMapKit.h"

@interface NearByDriversManager : NSObject

-(void) setNearByDriverModel : (NearByDriverModel*) model;
- (void) getNearbyDrivers : (CLLocationCoordinate2D) passengerLocation;

@end