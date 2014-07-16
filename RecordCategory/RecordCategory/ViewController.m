//
//  ViewController.m
//  RecordCategory
//
//  Created by lijian on 14-6-24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    AVAudioPlayer *_audioPlayer;
    AVAudioRecorder *_audioRecorder;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordBtn addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn setTitle:@"Record" forState:UIControlStateNormal];
    [recordBtn setBackgroundColor:[UIColor redColor]];
    [recordBtn setFrame:CGRectMake(50, 50, 100, 100)];
    [self.view addSubview:recordBtn];

    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopBtn addTarget:self action:@selector(stopAction:) forControlEvents:UIControlEventTouchUpInside];
    [stopBtn setTitle:@"Stop" forState:UIControlStateNormal];
    [stopBtn setBackgroundColor:[UIColor redColor]];
    [stopBtn setFrame:CGRectMake(200, 50, 100, 100)];
    [self.view addSubview:stopBtn];
    
    UIButton *routeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [routeBtn addTarget:self action:@selector(routeAction:) forControlEvents:UIControlEventTouchUpInside];
    [routeBtn setTitle:@"Route" forState:UIControlStateNormal];
    [routeBtn setBackgroundColor:[UIColor redColor]];
    [routeBtn setFrame:CGRectMake(50, 200, 100, 100)];
    [self.view addSubview:routeBtn];
    
    if (!_audioPlayer) {
        NSString *playerPath = [[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp3"];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:playerPath] error:NULL];
    }
    
    if (!_audioRecorder) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *recorderPath = [documentPath stringByAppendingPathComponent:@"1.m4a"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:recorderPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:recorderPath error:NULL];
        }
        _audioRecorder = [[[self class] createAudioRecorder:[NSURL fileURLWithPath:recorderPath]] retain];
    }
    
//    NSError *error = nil;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
//    if (error) {
//        NSLog(@"%@", [error description]);
//    }
}

- (void)stopAction:(id)sender {
    [_audioPlayer stop];
    [_audioRecorder stop];
}

- (void)recordAction:(id)sender {
    [self checkAndPrepareCategoryForRecording];
    
    [_audioPlayer play];
    [_audioRecorder record];
}

- (void)routeAction:(id)sender {
    [self getRoute];
}

+ (AVAudioRecorder *)createAudioRecorder:(NSURL *)url {
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSNumber *formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
    [recordSettings setObject:formatObject forKey: AVFormatIDKey];
    [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //[recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    
    NSError *error = nil;
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    if (error) {
        NSLog(@"Error: %@" , [error localizedDescription]);
    }
    [recordSettings release];
    return [recorder autorelease];
}

- (BOOL)hasMicphone {
    return [[AVAudioSession sharedInstance] isInputAvailable];
}

- (void)getRoute {
//    NSLog(@"%d", [self hasHeadset]);
//    CFDictionaryRef route;
//    UInt32 propertySize = sizeof(CFDictionaryRef);
//    AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &propertySize, &route);
    NSLog(@"%@", [[AVAudioSession sharedInstance] currentRoute]);
}

- (BOOL)hasHeadset {
#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: audio session code works only on a device
    return NO;
#else
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
 } else {
        NSString* routeStr = (NSString*)route;
        NSLog(@"AudioRoute: %@", routeStr);
        
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
#endif
    
}

- (void)resetOutputTarget {
    BOOL hasHeadset = [self hasHeadset];
    NSLog (@"Will Set output target is_headset = %@ .", hasHeadset ? @"YES" : @"NO");
    UInt32 audioRouteOverride = hasHeadset ?
kAudioSessionOverrideAudioRoute_None:kAudioSessionOverrideAudioRoute_Speaker;
//    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
}

- (BOOL)checkAndPrepareCategoryForRecording {
    BOOL hasMicphone = [self hasMicphone];
    NSLog(@"Will Set category for recording! hasMicophone = %@", hasMicphone?@"YES":@"NO");
    if (hasMicphone) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                               error:nil];
    }
//    [self resetOutputTarget];
    return hasMicphone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
