//
//  callTaxiViewController.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-4.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "callTaxiViewController.h"
#import "VoiceConverter.h"

@implementation callTaxiViewController

NSString* recordFileName = @"taxiRequestAudioRecord";

@synthesize recorder, player, convertAmr;


- (void)viewDidLoad
{
    [super viewDidLoad];
    player = [[AVAudioPlayer alloc]init];
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
    [_audioPlayBtn release];
    [super dealloc];
}

- (IBAction)sendTaxiRequest:(id)sender {
    if (recordFileName.length > 0){
        convertAmr = [recordFileName stringByAppendingString:@"wavToAmr"];
        
        //转格式
        [VoiceConverter wavToAmr:[VoiceRecorderBase getPathByFileName:recordFileName ofType:@"wav"] amrSavePath:[VoiceRecorderBase getPathByFileName:convertAmr ofType:@"amr"]];
        
    }
    
    if (convertAmr.length > 0){
        //转格式
        [VoiceConverter amrToWav:[VoiceRecorderBase getPathByFileName:convertAmr ofType:@"amr"] wavSavePath:[VoiceRecorderBase getPathByFileName:recordFileName ofType:@"wav"]];
    }
    
    if (recordFileName.length > 0) {
        player = [player initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBase getPathByFileName:recordFileName ofType:@"wav"]] error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
        player.volume = 1.0;
        [player play];
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


@end
