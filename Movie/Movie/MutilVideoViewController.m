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
    GPUMovieWriter *_movieWriter;
    
    CGAffineTransform preferredTransform;
    CGSize size;
}
@end

@implementation MutilVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        preferredTransform = CGAffineTransformIdentity;
        size = CGSizeMake(480, 480);
    }
    return self;
}

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
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn3 setFrame:CGRectMake(0, 434, 120, 50)];
    [btn3 setBackgroundColor:[UIColor redColor]];
    [btn3 setTitle:@"Write" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(writeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
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
        
        NSURL *videoURL4 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        CMTimeRange range4 = CMTimeRangeFromTimeToTime(CMTimeMakeWithSeconds(2, 600), CMTimeMakeWithSeconds(5, 600));
        MovieCompositon *c4 = [[MovieCompositon alloc] initWithURL:videoURL4 timeRange:range4];
        
        _baseMovie = [[GPUMutilMovie alloc] initWithVideos:@[c1, c2, c3, c4]];
    }
    
    [_baseMovie addTarget:_glView];
    
    [_baseMovie load];
}

- (void)writeAction
{
    NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480" ofType:@"mp4"]];
    [self initTransform:videoURL];
    
    if (!_movieWriter) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"2.MOV"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        _movieWriter = [[GPUMovieWriter alloc] initWithURL:[NSURL fileURLWithPath:path] size:size];
        _movieWriter.transform = preferredTransform;
        
        __block typeof(self) oneself = self;
        
        _movieWriter.finishBlock = ^{
            [oneself finishedBlock];
            oneself = nil;
        };
    }
    
    [_baseMovie addTarget:_movieWriter];
    
    [_movieWriter startWriting];
    
    [_baseMovie startProcessing];
}

- (void)finishedBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Write Finished" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
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

@end
