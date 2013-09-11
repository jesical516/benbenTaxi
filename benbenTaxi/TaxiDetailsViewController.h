//
//  TaxiDetailsViewController.h
//  benbenTaxi
//
//  Created by 晨松 on 13-9-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxiDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (retain, nonatomic) IBOutlet UITableView *detailTable;
@property (retain, nonatomic) IBOutlet UIButton *callDriverBtn;
@property (retain, nonatomic) IBOutlet UIButton *canclBtn;

@property (retain, nonatomic) IBOutlet UIView *finishBtn;
@end
