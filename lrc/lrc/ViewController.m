//
//  ViewController.m
//  lrc
//
//  Created by lijian on 14-6-13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ViewController.h"

#import "LrcParser.h"

#import "LrcScrollView.h"

#import <AVFoundation/AVFoundation.h>

#import "LrcStartView.h"

@interface ViewController ()
{
    AVAudioPlayer *audioPlayer;
    NSInteger _index;
    LrcScrollView *scollView;
    BOOL isStarted;
    
    NSTimer *timer;
}

@property (nonatomic, retain) NSArray *lrcKeys;
@property (nonatomic, assign) float startTime;
@property (nonatomic, assign) float offset;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _index = 0;
    
    Lrc *lrc = [LrcParser parseLrcWithFilePath:[[NSBundle mainBundle] pathForResource:@"01" ofType:@"lrc"]];
    NSLog(@"%@", lrc.description);
    
    self.lrcKeys = [lrc sortedLrcKeys];
    float firstTime = [[self.lrcKeys firstObject] floatValue];
    self.startTime = firstTime > 3.0 ? firstTime - 3.0 : 0.0;;
    self.offset = [lrc.offset floatValue];
    
    scollView = [[LrcScrollView alloc] initWithFrame:CGRectMake(24, 26, 192, 110)];
    scollView.backgroundColor = [UIColor clearColor];
    [scollView setDataSource:lrc];
    
    [self.view addSubview:scollView];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp3"]];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    
    [audioPlayer play];
    
    isStarted = NO;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)timerAction {
    if (!isStarted) {
        if (self.startTime <= audioPlayer.currentTime) {
            isStarted = YES;
            [scollView startCountDown];
        }
        
        return;
    }
    
    if (_lrcKeys && [_lrcKeys count] > _index) {
        if ([[_lrcKeys objectAtIndex:_index] doubleValue] - _offset <= audioPlayer.currentTime) {
            NSLog(@"%f, %f, %d", audioPlayer.currentTime, audioPlayer.duration, _index);
            ++_index;
            [scollView scrollToIndex:(_index - 1)];
            
            if (_index >= [_lrcKeys count]) {
                if (timer && [timer isValid]) {
                    [timer invalidate];
                    timer = nil;
                }
            }
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
