//
//  callTaxiViewController.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-4.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "callTaxiViewController.h"
#import "VoiceConverter.h"
#import "TaxiRequestModel.h"
#import "TaxiRequestManager.h"
#import "JSONKit.h"
#import "base64.h"

@implementation callTaxiViewController

NSString* recordFileName = @"taxiRequestAudioRecord";
TaxiRequestModel* taxiRequestmodel;
TaxiRequestManager* taxiRequestManager;

@synthesize recorder, player, convertAmr, convertWav;


- (void)viewDidLoad
{
    [super viewDidLoad];
    taxiRequestmodel = [[TaxiRequestModel alloc]init];
    [taxiRequestmodel setTaxiRequestStatus:FALSE];
    taxiRequestManager = [[TaxiRequestManager alloc]init];
    player = [[AVAudioPlayer alloc]init];
    recorder = [[VoiceRecorderBase alloc]init];
    recorder.vrbDelegate = self;
    
    UILongPressGestureRecognizer *longPrees = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(recordBtnLongPressed:)];
    longPrees.delegate = self;
    [_audioRecordBtn addGestureRecognizer:longPrees];
    [longPrees release];
    
    [taxiRequestManager setTaxiRequestModel:taxiRequestmodel];
    [taxiRequestmodel addObserver:self forKeyPath:@"request" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_locationDisplay release];
    [_audioRecordBtn release];
    [_audioPlayBtn release];
    [_sendRequestProcess release];
    [super dealloc];
}

- (IBAction)sendTaxiRequest:(id)sender {
    if (recordFileName.length > 0){
        convertAmr = [recordFileName stringByAppendingString:@"wavToAmr"];
        [VoiceConverter wavToAmr:[VoiceRecorderBase getPathByFileName:recordFileName ofType:@"wav"] amrSavePath:[VoiceRecorderBase getPathByFileName:convertAmr ofType:@"amr"]];
    }
    
    if (convertAmr.length > 0){
        self.convertWav = [recordFileName stringByAppendingString:@"amrToWav"];
        
        //转格式
        [VoiceConverter amrToWav:[VoiceRecorderBase getPathByFileName:convertAmr ofType:@"amr"] wavSavePath:[VoiceRecorderBase getPathByFileName:convertWav ofType:@"wav"]];
    }
    
    if (convertAmr.length > 0) {
        player = [player initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBase getPathByFileName:convertWav ofType:@"wav"]] error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
        player.volume = 1.0;
        [player play];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSData* audioData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBase getPathByFileName:convertWav]]];
    NSLog(@"here fuck %@", audioData);
    NSString* phoneNum = [prefs valueForKey:@"phone"];
    NSString* latitude = [prefs valueForKey:@"latitude"];
    NSString* longitude = [prefs valueForKey:@"longitude"];
    
    NSMutableDictionary *postInfoJobj = [NSMutableDictionary dictionary];
    NSMutableDictionary *userInfoJobj = [NSMutableDictionary dictionary];
    
    [userInfoJobj setObject : phoneNum forKey:@"passenger_mobile"];
    [userInfoJobj setObject : longitude forKey:@"passenger_lng"];
    [userInfoJobj setObject : latitude forKey:@"passenger_lat"];
    [userInfoJobj setObject : @"30" forKey:@"waiting_time_range"];
    [userInfoJobj setObject : @"amr" forKey:@"passenger_voice_format"];
    
    [postInfoJobj setObject : userInfoJobj forKey:@"taxi_request"];
    NSString *strPostInfo = [postInfoJobj JSONString];
    [taxiRequestManager sendTaxiRequest : strPostInfo];
    [self.sendRequestProcess startAnimating];
    NSFileManager * filemanager = [[[NSFileManager alloc]init] autorelease];
    if([filemanager fileExistsAtPath:[VoiceRecorderBase getPathByFileName:convertAmr]]){
        NSLog(@"Found here");
    }
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
        NSLog(@"record done");
    }
}
- (IBAction)audioPlay:(id)sender {
   if (recordFileName.length > 0) {
       player = [player initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBase getPathByFileName:recordFileName ofType:@"wav"]] error:nil];
       [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
       player.volume = 1.0;
       [player play];
    }
}

- (void)VoiceRecorderBaseRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName{
    NSLog(@"录音完成，文件路径:%@",_filePath);
    self.audioPlayBtn.hidden = FALSE;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"request"])
    {
        if([taxiRequestmodel getTaxiRequestStatus]) {
            [self performSegueWithIdentifier:@"TaxiRequestTrigger" sender:self];
        }
    }
}


@end
