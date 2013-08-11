//
//  callTaxiViewController.h
//  benbenTaxi
//
//  Created by 晨松 on 13-8-4.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoiceRecorderBase.h"

@interface callTaxiViewController : UIViewController <VoiceRecorderBaseDelegate,UIGestureRecognizerDelegate>

@property (retain, nonatomic) IBOutlet UILabel *locationDisplay;
@property (retain, nonatomic) IBOutlet UIButton *audioRecordBtn;

@property (retain, nonatomic)  VoiceRecorderBase *recorder;
@property (retain, nonatomic) IBOutlet UIButton *audioPlayBtn;
@property (retain, nonatomic) AVAudioPlayer *player;


@end