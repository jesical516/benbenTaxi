//
//  benbenTaxiLoginManager.h
//  benbenTaxi
//
//  Created by 晨松 on 13-7-23.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginModel.h"

@interface benbenTaxiLoginManager : NSObject

-(void) setLoginModel : (LoginModel*) model;
- (void) newAcountProcess : (NSString*) phoneNum : (NSString*) password;
@end
