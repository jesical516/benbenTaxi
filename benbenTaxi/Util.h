//
//  Util.h
//  benbenTaxi
//
//  Created by 晨松 on 13-9-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"

@interface Util : NSObject

+ (double) GetDistance : (CLLocationCoordinate2D) pt1 : (CLLocationCoordinate2D) pt2;
@end