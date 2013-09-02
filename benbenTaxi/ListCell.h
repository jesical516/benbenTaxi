//
//  ListCell.h
//  benbenTaxi
//
//  Created by 晨松 on 13-9-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *dayLabel;
@property (retain, nonatomic) IBOutlet UILabel *monthLabel;
@property (retain, nonatomic) IBOutlet UILabel *positionLabel;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;

@end
