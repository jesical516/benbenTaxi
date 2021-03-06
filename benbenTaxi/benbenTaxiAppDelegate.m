//
//  benbenTaxiAppDelegate.m
//  benbenTaxi
//
//  Created by 晨松 on 13-6-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "benbenTaxiAppDelegate.h"

@implementation benbenTaxiAppDelegate

bool firstOpen = true;
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"BFF9B1F6539715946EFCCCB6D0072086610DB5C9"  generalDelegate:nil];
    if (!ret) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"" delegate:self cancelButtonTitle:@"退出" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    self.window = [[[CustomWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.window.rootViewController = [storyBoard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    if([self.window isKindOfClass:[CustomWindow class]]) {
        NSLog(@"Fuck here");
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if(firstOpen == true) {
        firstOpen = false;
    } else {
        NSLog(@"applicationDidBecomeActive");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateStatus" object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end