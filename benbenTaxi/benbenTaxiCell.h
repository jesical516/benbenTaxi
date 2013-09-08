//
//  benbenTaxiCell.h
//  benbenTaxi
//
//  Created by 晨松 on 13-9-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface benbenTaxiCell : UITableViewCell {
    NSMutableArray *columns;
}

@property (retain, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (retain, nonatomic) IBOutlet UILabel *displayTitle;
@property (retain, nonatomic) IBOutlet UILabel *displayContent;

@end
