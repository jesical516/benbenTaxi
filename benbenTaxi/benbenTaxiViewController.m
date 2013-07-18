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
#import "MyBMKPointAnnotation.h"


@implementation benbenTaxiViewController
- (IBAction)callTaxiPressed:(id)sender {
}

- (void)viewDidLoad
{ 
    [super viewDidLoad];
    myMap.zoomLevel = 17;
    myMap.showsUserLocation = YES;
    isLocation = false;
}
- (IBAction)sendTaxiRequest:(id)sender {
}

-(void)viewWillAppear:(BOOL)animated {
    [myMap viewWillAppear];
    myMap.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    [self.sendRequestBtn setBackgroundColor];
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
/*
 * api使用
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
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    MyBMKPointAnnotation* annotation = [[MyBMKPointAnnotation alloc]init];
    annotation.coordinate = startPt;
    annotation.title = @"我在";
    [myMap addAnnotation:annotation];
    
    //定位成功后，需要获取到附近的taxi，并将其展现在地图上。
    //这里用到NUserDefaults的信息
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"phone is %@" , [prefs valueForKey:@"phone"]);
    NSLog(@"cookie is %@" , [prefs valueForKey:@"cookie"]);
    
    //获取到经纬度、登录cookie后，先请求一次附近的司机信息
    NSURL *url = [NSURL URLWithString:@"http://42.121.55.211:8081/api/v1/users/nearby_driver?lat=8&lng=8"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    NSString *cookieStr = [prefs valueForKey:@"cookie"];
    NSData* jsonData = [cookieStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *cookieDict = [jsonData objectFromJSONData];
    NSString *cookieKey = [cookieDict objectForKey:@"token_key"];
    NSLog(@"Cookie is %@", cookieKey);
    NSString *cookieValue = [cookieDict objectForKey:@"token_value"];
    NSLog(@"Cookie is %@", cookieValue);
    NSString *cookies = [cookieKey stringByAppendingString:@"="];
    cookies = [cookies stringByAppendingString:cookieValue];
    NSLog(@"Cookie is %@", cookies);
    //得到cookie的key和value
    [request setHTTPMethod:@"GET"];//设置请求方式为POST，默认为GET
    [request setValue: cookies forHTTPHeaderField:@"Cookie"];
    
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", str1);
    
    //这里需要将附近的司机信息展示出来
    
    CLLocationCoordinate2D driver1;//得到经纬度，用于展示图标
    driver1.latitude = 39.9204;
    driver1.longitude = 116.480;
    
    BMKPointAnnotation* driverAnnotation1 = [[BMKPointAnnotation alloc]init];
    driverAnnotation1.coordinate = driver1;
    driverAnnotation1.title = @"司机";
    
    CLLocationCoordinate2D driver2;//得到经纬度，用于展示图标
    driver2.latitude = 39.9205;
    driver2.longitude = 116.483;
    
    BMKPointAnnotation* driverAnnotation2 = [[BMKPointAnnotation alloc]init];
    driverAnnotation2.coordinate = driver2;
    driverAnnotation2.title = @"司机";
    
    NSArray *mapAnnotations = [[NSArray alloc] initWithObjects:driverAnnotation1, driverAnnotation2, nil];
    [myMap addAnnotations:mapAnnotations];
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
    startPt.latitude = userLocation.coordinate.latitude;
    startPt.longitude = userLocation.coordinate.longitude;
    
    float localLatitude=startPt.latitude;
    float localLongitude=startPt.longitude;
    CLGeocoder *Geocoder=[[CLGeocoder alloc]init];
    CLGeocodeCompletionHandler handler = ^(NSArray *place, NSError *error) {
        for (CLPlacemark *placemark in place) {
            cityName=placemark.locality;
            if(cityName == NULL) {
                cityName = placemark.administrativeArea;
            } 
            break;
        }
    };
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude: localLatitude longitude:localLongitude];
    [Geocoder reverseGeocodeLocation:loc completionHandler:handler];
    myMap.showsUserLocation = NO;
    myMap.centerCoordinate = startPt;
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}


- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    NSLog(@"called here");
    if ([annotation isKindOfClass:[MyBMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotation = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"] autorelease];
        newAnnotation.animatesDrop = YES;
	} else if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotation = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"] autorelease];
        newAnnotation.image = [UIImage imageNamed:@"steering.png"];
        newAnnotation.animatesDrop = YES;
		return newAnnotation;
	}
    
    return nil;

}
- (IBAction)taxiPressed:(id)sender {
    NSLog(@"Here");
}


- (void)dealloc {
    [_sendRequestBtn release];
    [super dealloc];
}
@end
