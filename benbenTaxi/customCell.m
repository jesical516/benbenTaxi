//
//  customCell.m
//  benbenTaxi
//
//  Created by 晨松 on 13-9-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "customCell.h"

@implementation customCell

@synthesize displayTitle, displayContent, image, title, content;

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
}

- (void)setImage:(NSString*) imageFile {
    self.image.image = [UIImage imageWithContentsOfFile:imageFile];
}

-(void)setTitle:(NSString *)n {
    if (![n isEqualToString: title]) {
        title = [n copy];
        self.displayTitle.text = title;
    }
}

-(void)setContent:(NSString *)d {
    if (![d isEqualToString:content]) {
        content = [d copy];
        self.displayContent.text = content;
    }
}


- (void)dealloc {
    [image release];
    [displayTitle release];
    [displayContent release];
    [super dealloc];
}
@end
