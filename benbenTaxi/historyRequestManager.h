//
//  historyRequestManager.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-31.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "historyRequestModel.h"

@interface historyRequestManager : NSObject

- (void) getHistoryRequest;
- (void) setModel : (historyRequestModel*) newModel;

@end
