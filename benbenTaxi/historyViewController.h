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

@interface historyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

}
@property (retain, nonatomic) IBOutlet UILabel *titleLable;

@property (retain, nonatomic) IBOutlet UITableView *requestTable;

@end