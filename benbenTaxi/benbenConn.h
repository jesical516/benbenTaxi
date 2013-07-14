//
//  benbenConn.h
//  benbenTaxi
//
//  Created by 晨松 on 13-7-14.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface benbenConn : NSObject
    //乘客注册
    +(bool) createPassenger: (NSString*) requestStr;
    //乘客登录
    +(bool) passengerLogin: (NSString*) requestStr;
    //乘客获取附近的driver
    +(bool) getNearbyDrivers: (NSString*) requestStr;
    //乘客发送打车请求
    +(bool) sendTaxiRequest : (NSString*) requestStr;
    //乘客确认打车请求
    +(bool) confirmTaxiRequest : (NSString*) requestStr;
@end