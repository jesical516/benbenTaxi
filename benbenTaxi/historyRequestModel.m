//
//  historyRequestModel.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-31.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "historyRequestModel.h"

@implementation historyRequestModel

- (bool) getStatus {
    return status;
}

- (void) setStatus : (bool) newStatus {
    status = newStatus;
}

- (bool) getCompleted {
    return completed;
}
- (void) setCompleted : (bool) isCompleted {
    completed = isCompleted;
}


@end
