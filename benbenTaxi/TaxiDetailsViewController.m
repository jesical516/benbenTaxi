//
//  TaxiDetailsViewController.m
//  benbenTaxi
//
//  Created by 晨松 on 13-9-2.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "TaxiDetailsViewController.h"
#import "JSONKit.h"
#import "benbenTaxiViewController.h"
#import "benbenTaxiCell.h"

@interface TaxiDetailsViewController ()

@end

@implementation TaxiDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_detailTable release];
    [_finishBtn release];
    [_callDriverBtn release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CustomCellIdentifier";
    
     benbenTaxiCell *cell = (benbenTaxiCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.displayTitle.text = @"请求ID";
    cell.displayContent.text = @"123";
    cell.thumbnailImageView.image = [UIImage imageNamed: @"mic.png"];
    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
