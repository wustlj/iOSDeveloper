//
//  WriterAppendImageViewController.m
//  Movie
//
//  Created by lijian on 14/11/11.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "WriterAppendImageViewController.h"

@interface WriterAppendImageViewController ()

@end

@implementation WriterAppendImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        preferredTransform = CGAffineTransformIdentity;
        size = CGSizeMake(480, 480);
    }
    return self;
}

- (void)dealloc
{
    [_baseMovie release];
    [_movieWriter release];
    
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
}

- (void)startAction
{
    __block typeof(self) weakself = self;
    
    if (!_appendImage) {
        UIImage *image = [UIImage imageNamed:@"WID-small.jpg"];
        _appendImage = [[GPUImage alloc] initWithImage:image];
    }

    
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"system1080*1920" ofType:@"MOV"]];
        [self initTransform:videoURL];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
        _baseMovie.completionBlock = ^{
            [weakself movieFinishedBlock];
        };
    }
    
    if (!_movieWriter) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"1.MOV"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        _movieWriter = [[GPUMovieWriter alloc] initWithURL:[NSURL fileURLWithPath:path] size:size];
        _movieWriter.transform = preferredTransform;
        
        _movieWriter.finishBlock = ^{
            [weakself finishedBlock];
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

- (void)movieFinishedBlock
{
    for (int i = 0; i < 30; i++) {
        [_baseMovie appendFramebuffer:_appendImage.outputFramebuffer];
    }
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
