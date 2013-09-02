//
//  Util.m
//  benbenTaxi
//
//  Created by 晨松 on 13-9-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "Util.h"
#import "BMapKit.h"

@implementation Util

+ (double) GetDistance : (CLLocationCoordinate2D) pt1 : (CLLocationCoordinate2D) pt2
{
    double lat1 = pt1.latitude;
    
    double lng1 = pt1.longitude;
    double lat2 = pt2.latitude;
    double lng2 = pt2.longitude;
    
    double EARTH_RADIUS = 6378.137;
    double radLat1 = (lat1 * M_PI) / 180.0;
    double radLat2 = (lat2 * M_PI) / 180.0;
    double a = radLat1 - radLat2;
    double b = (lng1 * M_PI) / 180.0  - (lng2 * M_PI) / 180.0 ;
    double s = 2 * sin(sqrt(pow(sin(a/2),2) + cos(radLat1)*cos(radLat2)*pow(sin(b/2),2)));
    s = s * EARTH_RADIUS;
    s = round(s * 10000) / 10000;
    return s;
}

@end