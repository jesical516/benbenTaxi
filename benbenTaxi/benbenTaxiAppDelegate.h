//
//  benbenTaxiAppDelegate.h
//  benbenTaxi
//
//  Created by 晨松 on 13-6-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"


#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "CustomWindow.h"
#import "benbenTaxiLogin.h"

@interface benbenTaxiAppDelegate : UIResponder <UIApplicationDelegate> {
    //CustomWindow* window;
    BMKMapManager* _mapManager;
}

@property (strong, nonatomic) CustomWindow *window;
@property (strong, nonatomic) benbenTaxiLogin *rootView;

@end