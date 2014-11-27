//
//  MVViewController.m
//  Movie
//
//  Created by lijian on 14/11/24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "MVViewController.h"
#import "GPUHeader.h"

@interface MVViewController ()
{
    GPUMV *_gpuMV;
    GPUView *_glView;
}
@end

@implementation MVViewController

- (void)viewDidLoad {
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

- (void)startAction {
    if (!_gpuMV) {
//        NSMutableArray *movies = [[NSMutableArray alloc] init];
//        [movies addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480" ofType:@"mp4"]]];
//        [movies addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]]];
//        [movies addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_3" ofType:@"mp4"]]];
        
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480" ofType:@"mp4"]];
        MovieComposition *c1 = [[MovieComposition alloc] initWithURL:videoURL];
        
        NSURL *videoURL2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        CMTimeRange range2 = CMTimeRangeFromTimeToTime(kCMTimeZero, CMTimeMakeWithSeconds(5, 600));
        MovieComposition *c2 = [[MovieComposition alloc] initWithURL:videoURL2 timeRange:range2];
        
        NSURL *videoURL3 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_3" ofType:@"mp4"]];
        CMTimeRange range3 = CMTimeRangeFromTimeToTime(kCMTimeZero, CMTimeMakeWithSeconds(5, 600));
        MovieComposition *c3 = [[MovieComposition alloc] initWithURL:videoURL3 timeRange:range3];
        
        NSURL *videoURL4 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        CMTimeRange range4 = CMTimeRangeFromTimeToTime(CMTimeMakeWithSeconds(2, 600), CMTimeMakeWithSeconds(5, 600));
        MovieComposition *c4 = [[MovieComposition alloc] initWithURL:videoURL4 timeRange:range4];
        
        _gpuMV = [[GPUMV alloc] initWithMovies:@[c1, c2, c3, c4]];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
    [_gpuMV loadMV:path];
}

@end
