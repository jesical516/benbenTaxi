//
//  callTaxiViewController.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-4.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "callTaxiViewController.h"

@implementation callTaxiViewController

NSString* recordFileName = @"taxiRequestAudioRecord";
@synthesize recorder;


- (void)viewDidLoad
{
    [super viewDidLoad];
    recorder = [[VoiceRecorderBase alloc]init];
    recorder.vrbDelegate = self;
    
    UILongPressGestureRecognizer *longPrees = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(recordBtnLongPressed:)];
    longPrees.delegate = self;
    [_audioRecordBtn addGestureRecognizer:longPrees];
    [longPrees release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_locationDisplay release];
    [_audioRecordBtn release];
    [super dealloc];
}

- (IBAction)sendTaxiRequest:(id)sender {
    
}

#pragma mark - 长按录音
- (void)recordBtnLongPressed:(UILongPressGestureRecognizer*) longPressedRecognizer{
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan) {
        _audioRecordBtn.highlighted = TRUE;
        NSLog(@"long pressed start");
        [recorder beginRecordByFileName:recordFileName];
    }//长按结束
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled){
        NSLog(@"长按事件");
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"消息" message:@"确定删除该模式吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
        
        [alert show];
        NSLog(@"long pressed end");
        _audioRecordBtn.highlighted = FALSE;
    }
}

- (void)VoiceRecorderBaseRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName{
    NSLog(@"录音完成，文件路径:%@",_filePath);
}


@end
