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
#import "Util.h"

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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* requestDetails = [prefs valueForKey:@"currentTaxiRequestDetail"];
    NSData *data = [requestDetails dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *taxiDict = [data objectFromJSONData];
    
    static NSString *simpleTableIdentifier = @"CustomCellIdentifier";
    
    benbenTaxiCell *cell = (benbenTaxiCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString* latStr = [taxiDict valueForKey:@"passenger_lat"];
    if( latStr == NULL) {
        NSLog(@"latitude is null");
    }
    
    NSString* requestState = [taxiDict valueForKey:@"state"];
    
    bool status = false;
    if([requestState isEqualToString:@"Success"]) {
        status = true;
    }
    
    cell.displayContent.text = @"null";
    
    switch (indexPath.row) {
        case 0:
            cell.displayTitle.text = @"请求ID";
            NSNumber* idNum = (NSNumber*)[taxiDict valueForKey:@"id"];
            NSNumberFormatter* formatter = [[NSNumberFormatter alloc]init];
            
            NSString* taxiID = [formatter stringFromNumber:idNum];
            cell.displayContent.text = taxiID;
            cell.thumbnailImageView.image = [UIImage imageNamed: @"flag.png"];
            break;
        case 1:
            cell.displayTitle.text = @"打车位置";
            cell.displayContent.text = [taxiDict valueForKey:@"source"];
            cell.thumbnailImageView.image = [UIImage imageNamed: @"user.png"];
            break;
        case 2:
            cell.displayTitle.text = @"司机车牌";
            if(status) {
                cell.displayContent.text = [taxiDict valueForKey:@"plate"];
            }
            cell.thumbnailImageView.image = [UIImage imageNamed: @"plate_11.png"];
            break;
        case 3:
            cell.displayTitle.text = @"司机电话";
            if(status) {
                cell.displayContent.text = [taxiDict valueForKey:@"driver_mobile"];
            }
            cell.thumbnailImageView.image = [UIImage imageNamed: @"phone_13.png"];
            break;
        case 4:
            cell.displayTitle.text = @"距离";
            cell.thumbnailImageView.image = [UIImage imageNamed: @"location.png"];
            
            if(status) {
                double lat1 = [[taxiDict valueForKey:@"passenger_lat"] doubleValue];
                double lng1 = [[taxiDict valueForKey:@"passenger_lng"] doubleValue];
                double lat2 = [[taxiDict valueForKey:@"driver_lat"] doubleValue];
                double lng2 = [[taxiDict valueForKey:@"driver_lng"] doubleValue];
            
                double distance = [Util CalculateDistance:lat1 : lng1: lat2 :lng2];
                cell.displayContent.text = [[NSString stringWithFormat:@"%.2f", distance] stringByAppendingString:@"公里"];
            }
            break;
        default:
            break;
    }
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(60.0f, 0.0f, 1.0f, 55.0f)];
    
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    
    [cell addSubview:lineView];
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
- (IBAction)callDriver:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* requestDetails = [prefs valueForKey:@"currentTaxiRequestDetail"];
    NSData *data = [requestDetails dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *taxiDict = [data objectFromJSONData];

    NSString *escapedPhoneNumber = [taxiDict valueForKey:@"driver_mobile"];
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
    [[UIApplication sharedApplication] openURL:telURL];
}
- (IBAction)returnBtnPressed:(id)sender {
    [self performSegueWithIdentifier:@"toHistory" sender:self];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* isFromHistory = [prefs valueForKey:@"IsFromHistory"];
    
    if ([identifier isEqualToString:@"isHistory"]) {
        if([isFromHistory isEqualToString:@"YES"]) {
            return TRUE;
        } else {
            return FALSE;
        }
    } else {
        if(![isFromHistory isEqualToString:@"YES"]) {
            return TRUE;
        } else {
            return FALSE;
        }
    }
}

@end
