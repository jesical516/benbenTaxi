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
#import "sys/utsname.h"
#import "Util.h"

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
    [super viewDidLoad];
    CGRect screedRect = [[UIScreen mainScreen] bounds];
    int offSet = screedRect.size.height - 568;
    
    CGRect newBtnRect = CGRectOffset(_callTaxiBtn.frame, 0, offSet);
    [_callTaxiBtn setFrame:newBtnRect];
    
    int mapHeight = screedRect.size.height - _callTaxiBtn.frame.size.height - 30 - 58;
    
    CGRect resizeMapRect = CGRectMake(0, 58, 320, mapHeight);
    [myMap setFrame:resizeMapRect];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus:) name:@"updateStatus" object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* lat = [prefs valueForKey : @"latitude"];
    NSString* lng = [prefs valueForKey : @"longitude"];
    
    CLLocationCoordinate2D prePt;
    prePt.latitude = [lat floatValue];
    prePt.longitude = [lng floatValue];
    
    myMap.zoomLevel = 14;
    
    if(prePt.latitude > 0 && prePt.longitude > 0) {
        myMap.centerCoordinate = prePt;
        passengerAnnotation = [[MyBMKPointAnnotation alloc]init];
        passengerAnnotation.coordinate = prePt;
        passengerAnnotation.title = detailAddress;
        [myMap addAnnotation:passengerAnnotation];
    }
    
    locationStatus = false;
    
    [self advertisingProcess];
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
    detailAddress = @"";
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
    myMap.showsUserLocation = TRUE;
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
        myMap.showsUserLocation = FALSE;
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
        
        NSLog(@"The location error is %@", errorInfo);
        
        for (CLPlacemark *placemark in place) {
            NSString* cityName = @"";
            NSString* thoroughfare = @"";
            thoroughfare = placemark.thoroughfare;
            cityName=placemark.locality;
            
            if(cityName == NULL) {
                cityName = placemark.administrativeArea;
            }
            if(cityName != NULL) {
                detailAddress = @"";
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
        newAnnotation.userInteractionEnabled = FALSE;
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
                NSString* responseDetail = [driverResponseModel valueForKey:@"driverResponseDetail"];
                NSString* distance = [self getFormatDistanceInfo : responseDetail];
                NSString* message = [[@"有司机响应，距离您约" stringByAppendingString : distance] stringByAppendingString : @"公里"];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"完成" otherButtonTitles:@"电话司机", nil];
                [alert show];
                
                TaxiProcessState = @"finish";
            } else if([currentStatus isEqualToString:@"TimeOut"]){
                TaxiProcessState = @"finish";
            }
        
        }
    }
}

-(void)updateStatus:(NSNotification*)notifi {
    [self setAdvertisingAction];
    myMap.showsUserLocation = true;
}

-(NSString*) getFormatDistanceInfo : (NSString*) responseInfo {
    NSLog(@"response is %@", responseInfo);
    NSData* responseData = [responseInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *driverResponseDict = [responseData objectFromJSONData];
    
    NSString* driverLat = [driverResponseDict valueForKey:@"driver_lat"];
    NSString* driverLng = [driverResponseDict valueForKey:@"driver_lng"];
    
    CLLocationCoordinate2D driverPt;
    driverPt.latitude = [driverLat doubleValue];
    driverPt.longitude = [driverLng doubleValue];
    
    double dis = [Util GetDistance : startPt : driverPt];
    NSString* result = [NSString stringWithFormat:@"%.2f", dis];
    return result;
}

-(void) requestTaxiState:(NSNotification*)notifi {
    TaxiProcessState = @"WaitingDriverResponse";
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
    [_callTaxiBtn release];
    [super dealloc];
}

- (void) setAdvertisingAction {
    CGRect frame = advertisingLabel.frame;
    CGSize dims = [advertisingLabel.text sizeWithFont:advertisingLabel.font];
    frame.origin.x = 0;      //设置起点
    [advertisingLabel setFrame:CGRectMake(frame.origin.x, frame.origin.y, dims.width, dims.height)];
    [UIView beginAnimations:@"testAnimation" context:NULL];
    [UIView setAnimationDuration:40.8f];     //动画执行时间
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
        TaxiProcessState = @"idle";
    } else {
        [driverResponseManager getDriverResponse:taxiRequestID];
    }
}

- (IBAction)audioRecordPressed:(id)sender {
    NSLog(@"audioRecordPressed debug");
    if([TaxiProcessState isEqualToString:@"WaitingDriverResponse"]) {
        NSMutableDictionary *taxiJobj = [NSMutableDictionary dictionary];
        
        [taxiJobj setObject : [NSNumber numberWithInteger:[taxiRequestID integerValue]] forKey:@"id"];
        [taxiJobj setObject : @"WaitingDriverResponse" forKey:@"state"];
        [taxiJobj setObject : detailAddress forKey:@"source"];
        NSString* currentTaxiInfo = [taxiJobj JSONString];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue: currentTaxiInfo forKey:@"currentTaxiRequestDetail"];
        [prefs setValue:@"NO" forKey : @"IsFromHistory"];
        [self performSegueWithIdentifier:@"taxiDetails" sender:self];
    } else {
        [self performSegueWithIdentifier:@"toCallTaxiView" sender:self];
    }
}

- (void) alertView:(UIAlertView *)alertview clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:[driverResponseModel valueForKey:@"driverResponseDetail"] forKey:@"currentTaxiRequestDetail"];
        [prefs setValue:@"NO" forKey : @"IsFromHistory"];
        [self performSegueWithIdentifier:@"taxiDetails" sender:self];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"taxiDetails"]) {
        if([TaxiProcessState isEqualToString:@"WaitingDriverResponse"]) {
            return true;
        }
        return FALSE;
    } else if( [identifier isEqualToString : @"toCallTaxiView"] ){
        if([TaxiProcessState isEqualToString:@"WaitingDriverResponse"]) {
            return false;
        } else {
            return true;
        }
    }
    
    return true;
}

@end
