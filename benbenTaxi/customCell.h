//
//  customCell.h
//  benbenTaxi
//
//  Created by 晨松 on 13-9-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *image;

@property (retain, nonatomic) IBOutlet UILabel *displayTitle;
@property (retain, nonatomic) IBOutlet UILabel *displayContent;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;

@end
