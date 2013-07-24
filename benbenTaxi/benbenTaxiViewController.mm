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
#import "locationModel.h"
#import "ASIHTTPRequest.h"


@implementation benbenTaxiViewController
- (IBAction)callTaxiPressed:(id)sender {
}

LocationModel *locationModel;


- (void)viewDidLoad
{ 
    [super viewDidLoad];
    myMap.zoomLevel = 17;
    myMap.showsUserLocation = YES;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    phoneNum = [prefs valueForKey:@"phone"];
    
    NSString *cookieStr = [prefs valueForKey:@"cookie"];
    NSData* jsonData = [cookieStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *cookieDict = [jsonData objectFromJSONData];
    NSString *cookieKey = [cookieDict objectForKey:@"token_key"];
    NSString *cookieValue = [cookieDict objectForKey:@"token_value"];
    
    NSLog(@"cookieKey:%@", cookieKey);
    NSLog(@"cookieValue:%@", cookieValue);
    
    NSString* cookiesTemp = [cookieKey stringByAppendingString:@"="];
    cookiesTemp = [cookiesTemp stringByAppendingString:cookieValue];
    NSLog(@"cookiesTemp:%@", cookiesTemp);
    locationModel = [[LocationModel alloc] init];
    [locationModel setValue:@"我在北京站" forKey:@"detailAddress"]; 
    [locationModel addObserver:self forKeyPath:@"detailAddress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];

}
- (IBAction)sendTaxiRequest:(id)sender {
    
}

-(void)viewWillAppear:(BOOL)animated {
    [myMap viewWillAppear];
    myMap.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    myMap.showsUserLocation = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [myMap viewWillDisappear];
    myMap.delegate = nil; // 不用时，置nil
    myMap.showsUserLocation = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    MyBMKPointAnnotation* annotation = [[MyBMKPointAnnotation alloc]init];
    annotation.coordinate = startPt;
    annotation.title = @"我在";
    [myMap addAnnotation:annotation];
}

- (void) setConnectionParams : ASIHTTPRequest : request {
    [request setHTTPMethod:@"GET"];//设置请求方式为POST，默认为GET
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *cookieStr = [prefs valueForKey:@"cookie"];
    NSData* jsonData = [cookieStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *cookieDict = [jsonData objectFromJSONData];
    NSString *cookieKey = [cookieDict objectForKey:@"token_key"];
    NSString *cookieValue = [cookieDict objectForKey:@"token_value"];
    NSString* cookiesTemp = [cookieKey stringByAppendingString:@"="];
    cookiesTemp = [cookiesTemp stringByAppendingString:cookieValue];
    [request setValue:  cookiesTemp forHTTPHeaderField:@"Cookie"];
}
/*
- (void) getNearbyDriversSucess {
    NSURL *url = [NSURL URLWithString:@"http://42.121.55.211:8081/api/v1/users/nearby_driver?lat=8&lng=8"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
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
*/
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
    myMap.centerCoordinate = startPt;
    [locationModel setPassengerLocation:startPt];
    /*
    if(![locationModel.getDetailAddress isEqualToString:@"我在"]) {
        [locationModel setValue:@"我在" forKey:@"detailAddress"];
    }*/
    
    myMap.showsUserLocation = NO;
    NSLog(@"address is %@", locationModel.getDetailAddress);
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
        newAnnotation.image = [UIImage imageNamed:@"icon_center_point.png"];
        newAnnotation.animatesDrop = YES;
        return newAnnotation;
	} else if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotation = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"] autorelease];
        newAnnotation.image = [UIImage imageNamed:@"steering.png"];
        newAnnotation.animatesDrop = YES;
		return newAnnotation;
	}
    
    return nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"here A");
    if([keyPath isEqualToString:@"detailAddress"])
    {
        MyBMKPointAnnotation* annotation = [[MyBMKPointAnnotation alloc]init];
        annotation.coordinate = startPt;
        annotation.title = @"我在";
        [myMap addAnnotation:annotation];
    }
}

- (IBAction)taxiPressed:(id)sender {
    
}


- (void)dealloc {
    [_sendRequestBtn release];
    [locationModel removeObserver:self forKeyPath:@"detailAddress"];
    [locationModel release];
    [super dealloc];
}

@end
