//
//  locationModel.h
//  benbenTaxi
//
//  Created by 晨松 on 13-7-21.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"

@interface LocationModel : NSObject {
}

//用户定位model的写
- (CLLocationCoordinate2D) getPassengerLocation;
- (NSString*) getDetailAddress;

//用户定为model的读
- (void) setPassengerLocation : (CLLocationCoordinate2D) newLocation;
- (void) setDetailAddress : (NSString*) newDetailAddress;

@end