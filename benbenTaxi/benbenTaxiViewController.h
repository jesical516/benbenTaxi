//
//  benbenTaxiViewController.h
//  benbenTaxi
//
//  Created by 晨松 on 13-6-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface benbenTaxiViewController : UIViewController
@property IBOutlet BMKMapView *myMap;
@property (weak, nonatomic) IBOutlet UILabel *appNameDisplay;
@end