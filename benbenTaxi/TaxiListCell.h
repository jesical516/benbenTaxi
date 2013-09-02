//
//  TaxiListCell.h
//  benbenTaxi
//
//  Created by 晨松 on 13-9-3.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxiListCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *dayLabel;

@property (retain, nonatomic) IBOutlet UILabel *monthLabel;

@property (retain, nonatomic) IBOutlet UILabel *statusLabel;

@property (retain, nonatomic) IBOutlet UILabel *positionLabel;

@end
