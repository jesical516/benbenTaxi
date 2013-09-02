//
//  ListCell.m
//  benbenTaxi
//
//  Created by 晨松 on 13-9-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "ListCell.h"

@implementation ListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_dayLabel release];
    [_monthLable release];
    [_positionLable release];
    [_statusLable release];
    [_dayLable release];
    [_dayLabel release];
    [_monthLabel release];
    [_positionLabel release];
    [_statusLabel release];
    [super dealloc];
}
@end
