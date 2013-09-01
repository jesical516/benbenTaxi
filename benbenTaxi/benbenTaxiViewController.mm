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
#import "callTaxiViewController.h"
#import "DriverResponseManager.h"
#import "DriverResponseModel.h"
#import "ResponseHandler.h"

@implementation benbenTaxiViewController

NSString* TaxiProcessState;
NSString* taxiRequestID;

NearByDriverModel* nearByDriverModel;
NearByDriversManager* nearByDriversManager;
NSArray *driverArray;
MyBMKPointAnnotation* passengerAnnotation;
AdvertisingModel* advertisingModel;
AdvertisingManager* advertisingManager;

NSTimer* advertisingTimer;
NSTimer* getDriverResponseTimer;

DriverResponseManager* driverResponseManager;
DriverResponseModel* driverResponseModel;
ResponseHandler* responseHandler;
bool locationStatus;
NSString  *detailAddress;

- (void)viewDidLoad
{ 
    NSLog(@"view did load");
    [super viewDidLoad];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* lat = [prefs valueForKey : @"latitude"];
    NSString* lng = [prefs valueForKey : @"longitude"];
    
    CLLocationCoordinate2D prePt;
    prePt.latitude = [lat floatValue];
    prePt.longitude = [lng floatValue];
    NSLog(@"%f, %f", prePt.latitude, prePt.longitude);
    
    myMap.centerCoordinate = prePt;
    
    passengerAnnotation = [[MyBMKPointAnnotation alloc]init];
    passengerAnnotation.coordinate = prePt;
    passengerAnnotation.title = detailAddress;
    
    [myMap addAnnotation:passengerAnnotation];
    
    [self advertisingProcess];
    myMap.zoomLevel = 15;
    myMap.showsUserLocation = YES;
    [self nearbyDriverProcess];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus:) name:@"updateStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestTaxiState:) name:@"requestID" object:nil];
    
    driverResponseManager = [[DriverResponseManager alloc]init];
    responseHandler = [[ResponseHandler alloc]init];
    driverResponseModel = [[DriverResponseModel alloc]init];
    [driverResponseManager setDriverResponseModel:driverResponseModel];
    [responseHandler setDriverResponseModel:driverResponseModel];
    
    [driverResponseModel addObserver:self forKeyPath:@"driverResponseDetail" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [driverResponseModel addObserver:self forKeyPath:@"confirmResponse" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    if( nil == advertisingTimer ) {
        advertisingTimer=[NSTimer scheduledTimerWithTimeInterval: 900
                                               target: self
                                             selector: @selector(handleTimer:)
                                             userInfo: nil
                                              repeats: YES];
    }
    
    getDriverResponseTimer = nil;
    locationStatus = false;
    detailAddress = @"";
    
    myMap.showsUserLocation = YES;
}

-(void) advertisingProcess {
    advertisingModel = [[AdvertisingModel alloc]init];
    advertisingManager = [[AdvertisingManager alloc]init];
    [advertisingManager setAdvertisingModel:advertisingModel];
    [advertisingModel addObserver:self forKeyPath:@"advertisingInfo" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* lastAdvertisingLabelText = [prefs valueForKey:@"advertisingLabelText"];
    
    if(![lastAdvertisingLabelText isEqualToString:@""]) {
        advertisingLabel.text = lastAdvertisingLabelText;
    }
    [self setAdvertisingAction];
    [advertisingManager updateAdvertisingInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus:) name:@"updateStatus" object:nil];
}

-(void) nearbyDriverProcess {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    phoneNum = [prefs valueForKey:@"phone"];
    nearByDriversManager = [[NearByDriversManager alloc]init];
    nearByDriverModel = [[NearByDriverModel alloc]init];
    [nearByDriverModel setNearByDriverInfo:@""];
    [nearByDriverModel setStatus:false];
    [nearByDriversManager setNearByDriverModel:nearByDriverModel];
    
    [nearByDriverModel addObserver:self forKeyPath:@"driverInfo" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    driverArray = nil;
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
    NSLog(@"%@", detailAddress);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue: detailAddress forKey:@"detailAddress"];
    
   
    if(nil != passengerAnnotation) {
        [myMap removeAnnotation:passengerAnnotation];
    }
    passengerAnnotation = [[MyBMKPointAnnotation alloc]init];
    passengerAnnotation.coordinate = startPt;
    passengerAnnotation.title = detailAddress;
    
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
    
    [self location];
    
    if(locationStatus) {
        NSLog(@"locationSucess");
        myMap.centerCoordinate = startPt;
        myMap.showsUserLocation = NO;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue: [NSString stringWithFormat:@"%f",startPt.latitude] forKey:@"latitude"];
        [prefs setValue: [NSString stringWithFormat:@"%f", startPt.longitude] forKey:@"longitude"];
    }
}

- (void) location {
    float localLatitude=startPt.latitude;
    float localLongitude=startPt.longitude;
    
    CLGeocoder *Geocoder=[[CLGeocoder alloc]init];
    CLGeocodeCompletionHandler handler = ^(NSArray *place, NSError *error) {
        NSString* errorInfo = [error localizedDescription];
        if(errorInfo == NULL || [errorInfo isEqualToString:@""]) {
            locationStatus = true;
        }
        
        for (CLPlacemark *placemark in place) {
            NSString* cityName = @"";
            NSString* thoroughfare = @"";
            thoroughfare = placemark.thoroughfare;
            cityName=placemark.locality;
            
            if(cityName == NULL) {
                cityName = placemark.administrativeArea;
            }
            if(cityName != NULL) {
                detailAddress = cityName;
                if(placemark.subLocality != NULL) {
                    detailAddress = [[detailAddress stringByAppendingString:placemark.subLocality]retain];
                }
                if(placemark.thoroughfare != NULL) {
                    detailAddress = [[detailAddress stringByAppendingString:placemark.thoroughfare]retain];
                }
                if(placemark.subThoroughfare != NULL) {
                    detailAddress = [[detailAddress stringByAppendingString:placemark.subThoroughfare]retain];
                }
                
                NSLog(@"detail address is %@", detailAddress);
                break;
            }
        }
    };
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude: localLatitude longitude:localLongitude];
    [Geocoder reverseGeocodeLocation:loc completionHandler:handler];
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
        //newAnnotation.animatesDrop = YES;
        return newAnnotation;
	} else if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotation = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"] autorelease];
        newAnnotation.image = [UIImage imageNamed:@"steering.png"];
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
    } else if( [keyPath isEqualToString:@"advertisingInfo"] ) {
        if( [advertisingModel getStatus]) {
            NSString* advertisingInfo = [advertisingModel valueForKey:@"advertisingInfo"];
            advertisingLabel.text = [@"=====欢迎使用奔奔打车=====" stringByAppendingString : advertisingInfo];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setValue: advertisingLabel.text forKey : @"advertisingLabelText"];
            [self setAdvertisingAction];
        }
    } else if([keyPath isEqualToString:@"driverResponseDetail"]) {
        NSLog(@"driver returns %@", [driverResponseModel valueForKey:@"requestStatus"]);
        if([driverResponseModel getDriverResponseStatus]) {
            [getDriverResponseTimer invalidate];
            NSString* currentStatus = [driverResponseModel valueForKey:@"requestStatus"];
            if([currentStatus isEqualToString:@"Success"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"有司机确认，距离您约0.2公里" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"", nil];
                [alert show];
                TaxiProcessState = @"finish";
            } else if([currentStatus isEqualToString:@"TimeOut"]){
                TaxiProcessState = @"finish";
            }
        
        }
    } else if ([keyPath isEqualToString:@"confirmResponse"]) {
        NSString *escapedPhoneNumber = @"18511585218";
        NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
        [[UIApplication sharedApplication] openURL:telURL];
    }
}

-(void)updateStatus:(NSNotification*)notifi {
    [self advertisingProcess];
    myMap.showsUserLocation = true;
}


-(void) requestTaxiState:(NSNotification*)notifi {
    NSString* taxiID = (NSString*) [notifi object];
    NSLog(@"Taxi id is %@", taxiID);
    taxiRequestID = taxiID;
    [driverResponseModel setValue:@"waiting_passenger_send_request" forKey:@"requestStatus"];
    
    NSLog(@"requestTaxiState");
    
    if( nil == getDriverResponseTimer ) {
        getDriverResponseTimer = [NSTimer scheduledTimerWithTimeInterval: 6
                                                          target: self
                                                        selector: @selector(sendRequestHandler:)
                                                        userInfo: nil
                                                         repeats: YES];
    }
}


- (void)dealloc {
    [_sendRequestBtn release];
    [advertisingLabel release];
    [advertisingLabel release];
    [super dealloc];
}

- (void) setAdvertisingAction {
    CGRect frame = advertisingLabel.frame;
    CGSize dims = [advertisingLabel.text sizeWithFont:advertisingLabel.font];
    frame.origin.x = 0;      //设置起点
    [advertisingLabel setFrame:CGRectMake(frame.origin.x, frame.origin.y, dims.width, dims.height)];
    [UIView beginAnimations:@"testAnimation" context:NULL];
    [UIView setAnimationDuration:30.8f];     //动画执行时间
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationRepeatCount:999999]; // 动画执行次数
    frame = advertisingLabel.frame;
    frame.origin.x = -dims.width;   //设置终点
    advertisingLabel.frame = frame;
    [UIView commitAnimations]; 
}

- (void) handleTimer : (id) sender {
    [advertisingManager updateAdvertisingInfo];
}

- (void) sendRequestHandler : (id) sender {
    if([TaxiProcessState isEqualToString:@"finish"]) {
        NSLog(@"go into stop");
        NSTimer* theTimer = (NSTimer*) sender;
        [theTimer invalidate];
    } else {
        [driverResponseManager getDriverResponse:taxiRequestID];
    }
}

- (IBAction)audioRecordPressed:(id)sender {
    
}

- (void) alertView:(UIAlertView *)alertview clickedButtonAtIndex:(NSInteger)buttonIndex{
}

@end
