//
//  benbenTaxiViewController.m
//  benbenTaxi
//
//  Created by 晨松 on 13-6-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "benbenTaxiViewController.h"
#import "BMapKit.h"
#import "BMKMapView.h"
#import "JSONKit.h"

@implementation benbenTaxiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    myMap.showsUserLocation = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [myMap viewWillAppear];
    myMap.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [myMap viewWillDisappear];
    myMap.delegate = nil; // 不用时，置nil
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = startPt;
	[myMap addAnnotation:annotation];
    //定位成功后，需要获取到附近的taxi，并将其展现在地图上。
    //这里用到NUserDefaults的信息
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"phone is %@" , [prefs valueForKey:@"phone"]);
    NSLog(@"cookie is %@" , [prefs valueForKey:@"cookie"]);
    /*
     /api/v1/users/nearby_driver
     get
     lng
     lat
     radius  搜索范围，单位米，默认5000
     time_range  搜索时间范围 单位分钟，默认值20
     请求示例
     /api/v1/users/nearby_driver?lat=8&lng=8
     response
     [{"driver_id":2,"created_at":"2013-06-01T20:48:55.984+08:00","lat":8.0,"lng":8.0},{"driver_id":4,"created_at":"2013-06-01T20:48:56.326+08:00","lat":8.0,"lng":8.0}]
     */

}

/**
 *用户位置更新后，会调用此函数
 *@param mapView 地图View
 *@param userLocation 新的用户位置
 */

- (void)mapView:(BMKMapView *)mapView didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
    NSLog(@"经度：%g",userLocation.coordinate.latitude);
    NSLog(@"纬度：%g",userLocation.coordinate.longitude);
    startPt.latitude = 40.056885;
    startPt.longitude = 116.30815;
    
    float localLatitude=40.056885;
    float localLongitude=116.30815;
    CLGeocoder *Geocoder=[[CLGeocoder alloc]init];
    CLGeocodeCompletionHandler handler = ^(NSArray *place, NSError *error) {
        for (CLPlacemark *placemark in place) {
            cityName=placemark.locality;
            if(cityName == NULL) {
                cityName = placemark.administrativeArea;
            }
            NSLog(@"cityName %@",cityName);
            break;
        }
    };
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude: localLatitude longitude:localLongitude];
    [Geocoder reverseGeocodeLocation:loc completionHandler:handler];
    myMap.showsUserLocation = NO;
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

@end
