//
//  ComfirmCodeModel.h
//  benbenTaxi
//
//  Created by 晨松 on 13-9-8.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComfirmCodeModel : NSObject {
    NSString* response;
    bool status;
}

-(bool) getStatus;
-(void) setStatus : (bool) newStatus;

@end
