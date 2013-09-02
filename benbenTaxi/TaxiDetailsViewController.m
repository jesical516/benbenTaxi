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
    NSString* requestDetail = [prefs valueForKey:@"currentTaxiRequestDetail"];
    NSData* tempData = [requestDetail dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* taxiDict = [tempData objectFromJSONData];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"infoRecord"];
    
    switch (indexPath.row) {
        case 0: {
            NSNumber* requestId = [taxiDict valueForKey:@"id"];
            NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
            NSString* taxiID = [numberFormatter stringFromNumber : requestId];
            NSLog(@"taxiID is %@", taxiID);
            if(NULL != taxiID) {
                cell.textLabel.text = taxiID;
            }
            break;
        }
        case 1:
            cell.textLabel.text = @"test";
            break;
        case 2:
            cell.textLabel.text = @"test";
            
            break;
        case 3:
            cell.textLabel.text = @"test";
            
            break;
        case 4:
            cell.textLabel.text = @"test";
            
            break;
        case 5:
            cell.textLabel.text = @"test";
            
            break;
        default:
            cell.textLabel.text = @"test";
            
            break;
    }
    return cell;
}

@end
