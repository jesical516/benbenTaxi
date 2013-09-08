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
        historyStatus = false;
        [_requestTable setHidden:TRUE];
        [historyManager getHistoryRequest];
        
        if (activity==NULL) {
            activity=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(145,165, 30, 100)];
        }
        activity.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
        activity.tag=600;
        activity.hidesWhenStopped=YES;
        [activity startAnimating];            //菊花开始转动
        [self.view addSubview:activity];
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
            NSLog(@"菊花停止转动");
            [activity stopAnimating];
            UIView *view=(UIView *)[self.view viewWithTag:600];
            [view removeFromSuperview];
            
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
    
    cell.dayLabel.text = @"null";
    cell.monthLabel.text = @"null";
    cell.positionLabel.text = @"null";
    cell.statusLabel.text = @"null";
    NSString* createDate = [taxiDict valueForKey:@"created_at"];
    if(NULL != createDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSArray *arrDatePos =[createDate componentsSeparatedByString:NSLocalizedString(@"T", nil)];
        NSDate *date = [dateFormatter dateFromString:arrDatePos[0]];
        
        NSLog(@"created time is %@ date is %@", createDate, date);
        [dateFormatter release];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
        
        NSInteger day = [components day];
        NSInteger month= [components month];
        
        cell.dayLabel.text = [[NSString stringWithFormat:@"%d", day] stringByAppendingString:@"日"];
        cell.monthLabel.text = [[NSString stringWithFormat:@"%d", month] stringByAppendingString:@"月"];
        ;
    }
    
    NSString* source = [taxiDict valueForKey:@"source"];
    if(![source isEqualToString:@""]) {
        cell.positionLabel.text = [taxiDict valueForKey:@"source"];
    }
    
    NSString* requestState = [taxiDict valueForKey:@"state"];
    if([requestState isEqualToString:@"Success"]) {
        cell.statusLabel.text = @"交易状态:成功";
    } else {
        cell.statusLabel.text = @"交易状态:失败";
    }
    
    NSLog(@"here we go");
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(50.0f, 0.0f, 1.0f, 40.0f)];
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    [cell addSubview:lineView];
    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"here");
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString* historyInfo = [historyModel valueForKey:@"historyRequestDetails"];
    NSData *data = [historyInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSArray* historyArr = (NSArray *)[data mutableObjectFromJSONData];
    NSDictionary *selectedRequestDict = [historyArr objectAtIndex:indexPath.row];
    NSString *selectedRequestDictStr = [selectedRequestDict JSONString];
    NSLog(@"request details is %@", selectedRequestDictStr);
    [prefs setValue:selectedRequestDictStr forKey:@"currentTaxiRequestDetail"];
    [prefs setValue:@"YES" forKey : @"IsFromHistory"];
    [self performSegueWithIdentifier:@"ToRequestDetail" sender:self];
}



- (void)dealloc {
    [_titleLable release];
    [_requestTable release];
    [super dealloc];
}
@end
