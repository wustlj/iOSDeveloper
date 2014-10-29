//
//  WriterViewController.m
//  Movie
//
//  Created by lijian on 14-10-29.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "WriterViewController.h"

@interface WriterViewController ()

@end

@implementation WriterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    // Do any additional setup after loading the view.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 64, 120, 50)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"Start" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startAction
{
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"system1920*1080" ofType:@"MOV"]];
        [self initTransform:videoURL];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    if (!_movieWriter) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"1.MOV"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        _movieWriter = [[GPUMovieWriter alloc] initWithURL:[NSURL fileURLWithPath:path] size:size];
        _movieWriter.transform = preferredTransform;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
