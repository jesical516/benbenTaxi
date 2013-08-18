//
//  TaxiRequestManager.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-18.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaxiRequestModel.h"

@interface TaxiRequestManager : NSObject {
    TaxiRequestModel* taxiRequestModel;
}


-(void) setTaxiRequestModel : (TaxiRequestModel*) newTaxiRequestModel;
-(void) sendTaxiRequest : (NSString*) postData;

@end
