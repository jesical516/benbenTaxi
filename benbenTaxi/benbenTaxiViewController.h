//
//  benbenTaxiViewController.h
//  benbenTaxi
//
//  Created by 晨松 on 13-6-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface benbenTaxiViewController :  UIViewController <BMKMapViewDelegate> {
    IBOutlet UILabel *titleDisplay;
    IBOutlet BMKMapView *myMap;
    NSString *cityName; //定义城市名，用于注册
    CLLocationCoordinate2D startPt;//得到经纬度，用于展示图标
    NSString *phoneNum; //本机号码，用于注册
    NSString *cookies;
}
@property (retain, nonatomic) IBOutlet UIButton *sendRequestBtn;

- (IBAction)textFieldDoneEditing:(id)sender;
@end