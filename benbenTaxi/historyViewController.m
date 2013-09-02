//
//  historyViewController.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-31.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "historyViewController.h"
#import "historyRequestManager.h"
#import "historyRequestModel.h"
#import "TaxiListCell.h"
#import "JSONKit.h"

@implementation historyViewController {
}
historyRequestModel* historyModel;
historyRequestManager* historyManager;
bool historyStatus;

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
    historyModel = [[historyRequestModel alloc]init];
    historyManager = [[historyRequestManager alloc]init];
    [historyManager setModel : historyModel];
    [historyModel addObserver:self forKeyPath:@"historyRequestDetails" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    if([historyModel getCompleted]) {
        NSLog(@"here getCompleted");
        historyStatus = true;
        [_requestTable setHidden:FALSE];
        
    } else {
        NSLog(@"here init");
        historyStatus = false;
        [_requestTable setHidden:TRUE];
        [historyManager getHistoryRequest];
    }
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"historyRequestDetails"])
    {
        if([historyModel getStatus]) {
            [historyModel setCompleted:TRUE];
            historyStatus = true;
            [_requestTable setHidden:FALSE];
            [_requestTable reloadData];
    } else {
            [historyManager getHistoryRequest];
        }
        
        NSLog(@"history get process done!");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!historyStatus) {
        return 0;
    } else {
        NSString* historyInfo = [historyModel valueForKey:@"historyRequestDetails"];
        NSData *data = [historyInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSArray* historyArr = (NSArray *)[data mutableObjectFromJSONData];
        return historyArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* historyInfo = [historyModel valueForKey:@"historyRequestDetails"];
    NSData *data = [historyInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSArray* historyArr = (NSArray *)[data mutableObjectFromJSONData];
    
    NSLog(@"indexPath %d", indexPath.row);
    NSDictionary *taxiDict = [historyArr objectAtIndex:indexPath.row];;
    
    NSString *identifier = @"ListIdentifier";
    
    TaxiListCell *cell = (TaxiListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    //NSString* createDate = [taxiDict valueForKey:@"created_at"];
    
    cell.dayLabel.text = @"1";
    cell.monthLabel.text = @"2";
    cell.positionLabel.text = [taxiDict valueForKey:@"source"];
    NSString* requestState = [taxiDict valueForKey:@"state"];
    if([requestState isEqualToString:@"Success"]) {
        cell.statusLabel.text = @"交易状态:成功";
    } else {
        cell.statusLabel.text = @"交易状态:失败";
    }
    NSLog(@"here we go");
    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}



- (void)dealloc {
    [_titleLable release];
    [_requestTable release];
    [super dealloc];
}
@end
