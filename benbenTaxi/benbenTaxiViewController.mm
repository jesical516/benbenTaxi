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
#import "ASIHTTPRequest.h"
#import "MyBMKUserLocation.h"
#import "MyBMKMapView.h"
#import "NearByDriverModel.h"
#import "NearByDriversManager.h"
#import "benbenTaxiAppDelegate.h"
#import "AdvertisingModel.h"
#import "AdvertisingManager.h"

@implementation benbenTaxiViewController

NearByDriverModel* nearByDriverModel;
NearByDriversManager* nearByDriversManager;
NSArray *driverArray;
MyBMKPointAnnotation* passengerAnnotation;
AdvertisingModel* advertisingModel;
AdvertisingManager* advertisingManager;

- (void)viewDidLoad
{ 
    NSLog(@"view did load");
    [super viewDidLoad];
    myMap.zoomLevel = 15;
    myMap.showsUserLocation = YES;
  
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    phoneNum = [prefs valueForKey:@"phone"];
    nearByDriversManager = [[NearByDriversManager alloc]init];
    nearByDriverModel = [[NearByDriverModel alloc]init];
    [nearByDriverModel setNearByDriverInfo:@""];
    [nearByDriverModel setStatus:false];
    [nearByDriversManager setNearByDriverModel:nearByDriverModel];
    
    [nearByDriverModel addObserver:self forKeyPath:@"driverInfo" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    driverArray = nil;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus:) name:@"updateStatus" object:nil];
    passengerAnnotation = nil;
    
    advertisingModel = [[AdvertisingModel alloc]init];
    advertisingManager = [[AdvertisingManager alloc]init];
    [advertisingManager setAdvertisingModel:advertisingModel];
    
}
- (IBAction)sendTaxiRequest:(id)sender {
    NSLog(@"driver info is %@", [nearByDriverModel getNearByDriverInfo]);
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
    if(nil != passengerAnnotation) {
        [myMap removeAnnotation:passengerAnnotation];
    }
    passengerAnnotation = [[MyBMKPointAnnotation alloc]init];
    passengerAnnotation.coordinate = startPt;
    passengerAnnotation.title = @"我在";
    [myMap addAnnotation:passengerAnnotation];
    [nearByDriversManager getNearbyDrivers:startPt];
}

/**
 *用户位置更新后，会调用此函数
 *@param mapView 地图View
 *@param userLocation 新的用户位置
 */

- (void)mapView:(BMKMapView *)mapView didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
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
    myMap.showsUserLocation = NO;
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}


- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MyBMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotation = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"] autorelease];
        //newAnnotation.image = [UIImage imageNamed:@"icon_center_point.png"];
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
    if([keyPath isEqualToString:@"driverInfo"])
    {
        if(nil != driverArray && driverArray.count > 0) {
            [myMap removeAnnotations:driverArray];
        }
        NSString* driverInfoStr = nearByDriverModel.getNearByDriverInfo;
        NSData *data = [driverInfoStr dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *arr = (NSArray *)[data mutableObjectFromJSONData];
        NSMutableArray* drivers = [NSMutableArray array];
        for(int i=0;i<arr.count;i++)
        {
            NSDictionary *driver = [arr objectAtIndex:i];
            NSNumber *driverID = [driver objectForKey:@"driver_id"];
            NSNumber* lat = [driver objectForKey:@"lat"];
            NSNumber* lng = [driver objectForKey:@"lng"];
            CLLocationCoordinate2D driverLocation;//得到经纬度，用于展示图标
            driverLocation.latitude = [lat.stringValue floatValue];
            driverLocation.longitude = [lng.stringValue floatValue];
            BMKPointAnnotation* driverAnnotation = [[BMKPointAnnotation alloc]init];
            driverAnnotation.coordinate = driverLocation;
            NSString* driverTitle = @"司机";
            driverTitle = [driverTitle stringByAppendingString:driverID.stringValue];
            driverAnnotation.title = driverTitle;
            [drivers addObject:driverAnnotation];
        }
        driverArray =  [drivers mutableCopy];;
        [myMap addAnnotations : driverArray];
    }
}

- (IBAction)taxiPressed:(id)sender {
    
}

-(void)updateStatus:(NSNotification*)notifi {
    myMap.showsUserLocation = true;
}

- (void)dealloc {
    [_sendRequestBtn release];
    [super dealloc];
}

- (void) 

@end
