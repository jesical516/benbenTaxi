//
//  benbenTaxiCell.m
//  benbenTaxi
//
//  Created by 晨松 on 13-9-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "benbenTaxiCell.h"

@implementation benbenTaxiCell

@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize displayTitle = _displayTitle;
@synthesize displayContent = _displayContent;

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
    [_thumbnailImageView release];
    [_displayTitle release];
    [_displayContent release];
    [super dealloc];
}
@end
