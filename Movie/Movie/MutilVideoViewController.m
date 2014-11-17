//
//  MutilVideoViewController.m
//  Movie
//
//  Created by lijian on 14/11/13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "MutilVideoViewController.h"

@interface MutilVideoViewController ()
{
    GPUMutilMovie *_baseMovie;
    GPUView *_glView;
}
@end

@implementation MutilVideoViewController

- (void)dealloc {
    [_baseMovie release];
    [_glView release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 64, 120, 50)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"Start" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setFrame:CGRectMake(150, 64, 120, 50)];
    [btn2 setBackgroundColor:[UIColor redColor]];
    [btn2 setTitle:@"Load" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(loadAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    _glView = [[GPUView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn.frame), 320, 320)];
    [self.view addSubview:_glView];
}

- (void)startAction
{
    [_baseMovie startProcessing];
}

- (void)loadAction
{
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480" ofType:@"mp4"]];
        MovieCompositon *c1 = [[MovieCompositon alloc] initWithURL:videoURL];
        
        NSURL *videoURL2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        CMTimeRange range2 = CMTimeRangeFromTimeToTime(kCMTimeZero, CMTimeMakeWithSeconds(5, 600));
        MovieCompositon *c2 = [[MovieCompositon alloc] initWithURL:videoURL2 timeRange:range2];
        
        NSURL *videoURL3 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_3" ofType:@"mp4"]];
        CMTimeRange range3 = CMTimeRangeFromTimeToTime(kCMTimeZero, CMTimeMakeWithSeconds(5, 600));
        MovieCompositon *c3 = [[MovieCompositon alloc] initWithURL:videoURL3 timeRange:range3];
        
        NSURL *videoURL4 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_3" ofType:@"mp4"]];
        CMTimeRange range4 = CMTimeRangeFromTimeToTime(CMTimeMakeWithSeconds(2, 600), CMTimeMakeWithSeconds(5, 600));
        MovieCompositon *c4 = [[MovieCompositon alloc] initWithURL:videoURL4 timeRange:range4];
        
        _baseMovie = [[GPUMutilMovie alloc] initWithVideos:@[c1, c2, c3, c4]];
    }
    
    [_baseMovie addTarget:_glView];
    
    [_baseMovie load];
}

@end
