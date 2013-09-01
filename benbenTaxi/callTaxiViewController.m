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
    sendRequestStatus = false;
    requestCancelStatus = false;
    
    NSString* armFileName = [VoiceRecorderBase getPathByFileName:recordFileName ofType:@"wav"];
    if([VoiceRecorderBase fileExistsAtPath : armFileName]) {
        [VoiceRecorderBase deleteFileAtPath: armFileName];
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* detailAddress = [prefs valueForKey:@"detailAddress"];
    self.locationDisplay.text = [@"位置:" stringByAppendingString : detailAddress];
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
    NSString* filename = [VoiceRecorderBase getPathByFileName:recordFileName ofType:@"wav"];
    
    if(![VoiceRecorderBase fileExistsAtPath : filename]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先录音" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    } else {
        if (recordFileName.length > 0){
            convertAmr = [recordFileName stringByAppendingString:@"wavToAmr"];
            [VoiceConverter wavToAmr:[VoiceRecorderBase getPathByFileName:recordFileName ofType:@"wav"] amrSavePath:[VoiceRecorderBase getPathByFileName:convertAmr ofType:@"amr"]];
        }
       
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* detailsAddress = [prefs valueForKey:@"detailAddress"];
        NSData* audioData = [[NSData alloc] initWithContentsOfFile:[VoiceRecorderBase getPathByFileName:convertAmr ofType:@"amr"]];
        Byte* inputData = (Byte*)[audioData bytes];
        size_t inputDataSize = (size_t)[audioData length];
        size_t outputDataSize = EstimateBas64EncodedDataSize(inputDataSize);
        char outputData[outputDataSize];
    
        Base64EncodeData(inputData, inputDataSize, outputData, &outputDataSize, FALSE);
        NSString* audioStr = [[NSString alloc] initWithCString:outputData];
        NSString* phoneNum = [prefs valueForKey:@"phone"];
        NSString* latitude = [prefs valueForKey:@"latitude"];
        NSString* longitude = [prefs valueForKey:@"longitude"];
    
        NSMutableDictionary *postInfoJobj = [NSMutableDictionary dictionary];
        NSMutableDictionary *userInfoJobj = [NSMutableDictionary dictionary];
    
        [userInfoJobj setObject : phoneNum forKey:@"passenger_mobile"];
        [userInfoJobj setObject : longitude forKey:@"passenger_lng"];
        [userInfoJobj setObject : latitude forKey:@"passenger_lat"];
        [userInfoJobj setObject : @"5" forKey:@"waiting_time_range"];
        [userInfoJobj setObject : @"amr" forKey:@"passenger_voice_format"];
        [userInfoJobj setObject : audioStr forKey:@"passenger_voice"];
        [userInfoJobj setObject : detailsAddress forKey:@"source"];
        
    
        [postInfoJobj setObject : userInfoJobj forKey:@"taxi_request"];
        NSString *strPostInfo = [postInfoJobj JSONString];
        [taxiRequestManager sendTaxiRequest : strPostInfo];
        [self.sendRequestProcess startAnimating];
    }
}

#pragma mark - 长按录音
- (void)recordBtnLongPressed:(UILongPressGestureRecognizer*) longPressedRecognizer{
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan) {
        _audioRecordBtn.highlighted = TRUE;
        _audioRecordBtn.showsTouchWhenHighlighted = TRUE;
        _audioRecordBtn.backgroundColor = [UIColor redColor];
        NSLog(@"long pressed start");
        [recorder beginRecordByFileName:recordFileName];
    }//长按结束
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled){
        _audioRecordBtn.showsTouchWhenHighlighted = FALSE;
        _audioRecordBtn.backgroundColor = [UIColor clearColor];
        
        NSLog(@"long pressed end");
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
            sendRequestStatus = TRUE;
            NSString* requestID = [taxiRequestmodel valueForKey:@"request"];
            NSLog(@"request id is %@", requestID);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"requestID" object:requestID];
            [self performSegueWithIdentifier:@"TaxiRequestTrigger" sender:self];
        } else {
            sendRequestStatus = FALSE;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"失败" message:@"网络不给力，请稍后再试..." delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (IBAction)requestCancelPressed:(id)sender {
    requestCancelStatus = true;
    [self performSegueWithIdentifier:@"TaxiRequestTrigger" sender:self];
}

@end
