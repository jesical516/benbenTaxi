//
//  ComfirmCodeManager.h
//  benbenTaxi
//
//  Created by 晨松 on 13-9-8.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ComfirmCodeModel.h"

@interface ComfirmCodeManager : NSObject

-(void) setComfirmCodeModel : (ComfirmCodeModel*) comfirmCodeModel;
- (void) getConfirmCode : (NSString*) phoneNum;

@end
