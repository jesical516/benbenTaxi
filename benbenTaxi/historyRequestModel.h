//
//  historyRequestModel.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-31.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface historyRequestModel : NSObject {
    bool status;
    NSString* historyRequestDetails;
    bool completed;
}

- (bool) getStatus;
- (void) setStatus : (bool) newStatus;

- (bool) getCompleted;
- (void) setCompleted : (bool) isCompleted;


@end
