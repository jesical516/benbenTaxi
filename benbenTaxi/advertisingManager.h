//
//  AdvertisingManager.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-4.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvertisingModel.h"

@interface AdvertisingManager : NSObject

- (void) setAdvertisingModel : (AdvertisingModel*) newModel;
- (void) updateAdvertisingInfo;

@end
