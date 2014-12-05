//
//  TestViewController.m
//  Movie
//
//  Created by lijian on 14/12/1.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "TestViewController.h"

#import "GPUReverseMovie.h"

#import "GPUHeader.h"

@interface TestViewController ()
{
    GPUReverseMovie *_baseMovie;
    GPUView *_glView;
    GPUMovieWriter *_movieWriter;
    
    CGAffineTransform preferredTransform;
    CGSize size;
}
@end

@implementation TestViewController

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
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"0" ofType:@"mp4"]];
        [self initTransform:videoURL];
        _baseMovie = [[GPUReverseMovie alloc] initWithURL:videoURL];
    }
    
    if (!_movieWriter) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Reverse.mp4"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        _movieWriter = [[GPUMovieWriter alloc] initWithURL:[NSURL fileURLWithPath:path] size:size];
        _movieWriter.transform = preferredTransform;
        
        __block typeof(self) oneself = self;
        
        _movieWriter.finishBlock = ^{
            [oneself finishedBlock];
        };
    }
    
    [_baseMovie addTarget:_movieWriter];
    
    [_movieWriter startWriting];
    
    [_baseMovie startProcessing];
}

- (void)initTransform:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetTrack *assetTrack = nil;
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    preferredTransform = assetTrack.preferredTransform;
    size = assetTrack.naturalSize;
}

- (void)finishedBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Write Finished" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}

@end
