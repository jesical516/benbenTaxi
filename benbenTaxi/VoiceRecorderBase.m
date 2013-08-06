//
//  VoiceRecorderBase.m
//  benbenTaxi
//
//  Created by 晨松 on 13-8-6.
//  Copyright (c) 2013年 晨松. All rights reserved.
//

#import "VoiceRecorderBase.h"

@implementation VoiceRecorderBase
@synthesize vrbDelegate,maxRecordTime,recordFileName,recordFilePath;

/**
 生成当前时间字符串
 @returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[[NSDateFormatter  alloc]init]autorelease];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}


/**
 获取缓存路径
 @returns 缓存路径
 */
+ (NSString*)getCacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0]stringByAppendingPathComponent:@"Voice"];
}

/**
 判断文件是否存在
 @param _path 文件路径
 @returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:_path];
}

/**
 删除文件
 @param _path 文件路径
 @returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

/**
 生成文件路径
 @param _fileName 文件名
 @param _type 文件类型
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[VoiceRecorderBase getCacheDirectory]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    return fileDirectory;
}

/**
 生成文件路径
 @param _fileName 文件名
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName{
    NSString* fileDirectory = [[VoiceRecorderBase getCacheDirectory]stringByAppendingPathComponent:_fileName];
    return fileDirectory;
}

/**
 获取录音设置
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   //                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return [recordSetting autorelease];
}

- (void)beginRecordByFileName:(NSString*)_fileName;{
    
    //设置文件名和录音路径
    self.recordFileName = _fileName;
    self.recordFilePath = [VoiceRecorderBase getPathByFileName:recordFileName ofType:@"wav"];
    
    //初始化录音
    self.recorder = [[[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:recordFilePath]
                                                settings:[VoiceRecorderBase getAudioRecorderSettingDict]
                                                   error:nil]autorelease];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    
    NSLog(@"beginRecordByFileName");
    
    //还原计数
    curCount = 0;
    //还原发送
    canNotSend = NO;
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self.recorder record];
    
    //启动计时器
    [self startTimer];
    [self addScreenTouchObserver];
}

#pragma mark - AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"录音停止");
    
    [self stopTimer];
    curCount = 0;
}
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    NSLog(@"录音开始");
    [self stopTimer];
    curCount = 0;
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
    NSLog(@"录音中断");
    [self stopTimer];
    curCount = 0;
}
#pragma mark - 启动定时器
- (void)startTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    NSLog(@"startTimer");
}

#pragma mark - 添加触摸观察者
- (void)addScreenTouchObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScreenTouch:) name:@"nScreenTouch" object:nil];
    NSLog(@"addScreenTouchObserver");
}

#pragma mark - 停止定时器
- (void)stopTimer{
    if (timer && timer.isValid){
        [timer invalidate];
        timer = nil;
    }
}


#pragma mark - 更新音频峰值
- (void)updateMeters{
    if (self.recorder.isRecording){
        
        //更新峰值
        [self.recorder updateMeters];
        curCount += 0.1f;
    }
}

//传递触点
- (void)transferTouch:(UITouch*)_touch{
    CGPoint point = [_touch locationInView:nil];
    switch (_touch.phase) {
        case UITouchPhaseBegan:
            [self touchBegan:point];
            break;
        case UITouchPhaseMoved:
            [self touchMoved:point];
            break;
        case UITouchPhaseCancelled:
        case UITouchPhaseEnded:
            [self touchEnded:point];
            break;
        default:
            break;
    }
}
#pragma mark - 触摸开始
- (void)touchBegan:(CGPoint)_point{
    curTouchPoint = _point;
    NSLog(@"touchBegan");
}
#pragma mark - 触摸移动
- (void)touchMoved:(CGPoint)_point{
    curTouchPoint = _point;
    NSLog(@"touchMoved");
}
#pragma mark - 触摸结束
- (void)touchEnded:(CGPoint)_point{
    //停止计时器
    NSLog(@"touchEnded");

    [self stopTimer];
    
    curTouchPoint = CGPointZero;
    [self removeScreenTouchObserver];
    
    if (self.recorder.isRecording)
        [self.recorder stop];
    
    if ([self.vrbDelegate respondsToSelector:@selector(VoiceRecorderBaseRecordFinish:fileName:)]) {
                [self.vrbDelegate VoiceRecorderBaseRecordFinish:recordFilePath fileName:recordFileName];
    }
}
#pragma mark - 移除触摸观察者
- (void)removeScreenTouchObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"nScreenTouch" object:nil];//移除nScreenTouch事件
}

-(void)onScreenTouch:(NSNotification *)notification {
    NSLog(@"onScreenTouch");
    UIEvent *event=[notification.userInfo objectForKey:@"data"];
    NSSet *allTouches = event.allTouches;
    
    //如果未触摸或只有单点触摸
    if ((curTouchPoint.x == CGPointZero.x && curTouchPoint.y == CGPointZero.y) || allTouches.count == 1)
        [self transferTouch:[allTouches anyObject]];
    else{
        //遍历touch,找到最先触摸的那个touch
        for (UITouch *touch in allTouches){
            CGPoint prePoint = [touch previousLocationInView:nil];
            
            if (prePoint.x == curTouchPoint.x && prePoint.y == curTouchPoint.y)
                [self transferTouch:touch];
        }
    }
}

@end