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

@interface historyViewController ()

@end

@implementation historyViewController

@synthesize model, manager;


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
    [self.model addObserver:self forKeyPath:@"historyRequestDetails" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    [self.manager setModel : self.model];
    [self.manager getHistoryRequest];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
