//
//  MyMapAnnotation.m
//  benbenTaxi
//
//  Created by 晨松 on 13-7-9.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "MyMapAnnotation.h"

#import "BMapKit.h"
#import "BMKMapView.h"
@implementation MyMapAnnotation

@synthesize location;
@synthesize title;
@synthesize subtitle;
@synthesize headImage;

-(void)dealloc {
    [super dealloc];
}

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        location = coord;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    location = newCoordinate;
}

@end
