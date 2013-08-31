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

@implementation historyViewController {
    NSArray *recipes;
}
historyRequestModel* historyModel;
historyRequestManager* historyManager;

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
    [historyRequestModel addObserver:self forKeyPath:@"historyRequestDetails" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    historyModel = [[historyRequestModel alloc]init];
    historyManager = [[historyRequestManager alloc]init];
    [historyManager setModel : historyModel];
    [historyManager getHistoryRequest];
    
    recipes = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
    //NSLog(@"recipes is %d", [recipes count]);
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
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"recipes is here");
    return 16;
    //return [recipes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"requestDetail";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    //cell.textLabel.text = [recipes objectAtIndex:indexPath.row];
    cell.textLabel.text = @"Test";
    return cell;
}

- (void)dealloc {
    [_titleLable release];
    [_requestTable release];
    [super dealloc];
}
@end
