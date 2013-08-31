//
//  historyViewController.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-31.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "historyRequestModel.h"
#import "historyRequestManager.h"

@interface historyViewController : UIViewController

@property (copy, nonatomic) historyRequestModel* model;
@property (copy, nonatomic) historyRequestManager* manager;        //amr转wav的文件名

@end