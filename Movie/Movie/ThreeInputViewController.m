//
//  ThreeInputViewController.m
//  Movie
//
//  Created by lijian on 14/11/13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ThreeInputViewController.h"

@interface ThreeInputViewController ()

@end

@implementation ThreeInputViewController

- (void)dealloc
{
    [_glView release];
    [_baseMovie release];
    [_overMovie release];
    [_alphaMovie release];
    [_filter release];
    
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
    
    _glView = [[GPUView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn.frame), 320, 320)];
    [self.view addSubview:_glView];
}

- (void)startAction
{
    
    if (!_overMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"trans_1" ofType:@"mp4"]];
        _overMovie = [[GPUMovie alloc] initWithURL:videoURL];
        _overMovie.isMask = YES;
        [_overMovie startProcessing];
    }
    
    if (!_alphaMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"trans_1_mask" ofType:@"mp4"]];
        _alphaMovie = [[GPUMovie alloc] initWithURL:videoURL];
        _alphaMovie.isMask = YES;
        [_alphaMovie startProcessing];
    }
    
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480" ofType:@"mp4"]];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
        __block GPUMovie *weakOverMovie = _overMovie;
        __block GPUMovie *weakAlphaMovie = _alphaMovie;
        _baseMovie.currentFrameCompletionBlock = ^{
            [weakOverMovie readNextVideoFrame];
            [weakAlphaMovie readNextVideoFrame];
        };
    }
    
    if (!_filter) {
        _filter = [[GPUThreeInputFilter alloc] init];
    }
    
    [_baseMovie addTarget:_filter];
    [_overMovie addTarget:_filter];
    [_alphaMovie addTarget:_filter];
    
    [_filter addTarget:_glView];
    
    [_baseMovie startProcessing];
}

@end
