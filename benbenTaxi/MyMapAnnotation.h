//
//  MyMapAnnotation.h
//  benbenTaxi
//
//  Created by 晨松 on 13-7-9.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"
#import "BMKMapView.h"

@interface MyMapAnnotation : NSObject<BMKAnnotation> {
    CLLocationCoordinate2D location;
    NSString *title;
    NSString *subtitle;
    NSString *headImage;
}

@property CLLocationCoordinate2D location;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *headImage;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
