//
//  TwoInputViewController.m
//  Movie
//
//  Created by lijian on 14/11/12.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "TwoInputViewController.h"

@interface TwoInputViewController ()

@end

@implementation TwoInputViewController

- (void)dealloc
{
    [_glView release];
    [_baseMovie release];
    [_maskMovie release];
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
    if (!_maskMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"PTstar" ofType:@"mp4"]];
        _maskMovie = [[GPUMovie alloc] initWithURL:videoURL];
        _maskMovie.isMask = YES;
        [_maskMovie startProcessing];
    }
    
    __block GPUMovie *weakMaskMovie = _maskMovie;
    
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480" ofType:@"mp4"]];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
        _baseMovie.currentFrameCompletionBlock = ^{
            [weakMaskMovie readNextVideoFrame];
        };
    }
    
    if (!_filter) {
        _filter = [[GPUTwoInputFilter alloc] init];
    }
    
    [_baseMovie addTarget:_filter];
    [_maskMovie addTarget:_filter];
    
    [_filter addTarget:_glView];
    
    [_baseMovie startProcessing];
}

@end
