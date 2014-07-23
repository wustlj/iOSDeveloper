//
//  ViewController.m
//  Movie
//
//  Created by lijian on 14-7-2.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "GPUView.h"
#import "GPUContext.h"

#import "GPUMovie.h"
#import "GPUFilter.h"
#import "GPUTwoInputFilter.h"
#import "GPUThreeInputFilter.h"
#import "GPULineFilter.h"
#import "GPUPartFilter.h"

@interface ViewController ()
{
    GPUView *_glView;
    GPUView *_glView2;
    
    GPUMovie *_baseMovie;
    GPUMovie *_overMovie;
    GPUMovie *_maskMovie;
    GPUMovie *_movie3;
    
    GPUFilter *_filter;
}
@end

@implementation ViewController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    _glView = [[GPUView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [self.view addSubview:_glView];
    [_glView release];
    
    _glView2 = [[GPUView alloc] initWithFrame:CGRectMake(120, 320, 200, 200)];
    [self.view addSubview:_glView2];
    [_glView2 release];
        
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 320, 120, 50)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"Begin" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startPartFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setFrame:CGRectMake(0, 470, 120, 50)];
    [btn2 setBackgroundColor:[UIColor redColor]];
    [btn2 setTitle:@"Begin" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(startRead2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

#pragma mark - Action

- (void)startPartFilter {
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    if (!_filter) {
        _filter = [[GPUPartFilter alloc] init];
    }
    
    [_baseMovie addTarget:_filter];
    [_filter addTarget:_glView];
    
    [_baseMovie startProcessing];
}

- (void)startLineFilter {
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    if (!_filter) {
        _filter = [[GPULineFilter alloc] init];
    }
    
    [_baseMovie addTarget:_filter];
    [_filter addTarget:_glView];
    
    [_baseMovie startProcessing];
}

- (void)startFilter {
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    if (!_filter) {
        _filter = [[GPUFilter alloc] init];
    }
    
    [_baseMovie addTarget:_filter];
    [_filter addTarget:_glView];
    
    [_baseMovie startProcessing];
}

- (void)startTwoFilter {
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    if (!_overMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"PTstar" ofType:@"mp4"]];
        _overMovie = [[GPUMovie alloc] initWithURL:videoURL];
        _overMovie.textureIndex = 1;
        _overMovie.keepLooping = NO;
        [_overMovie startProcessing];
    }
    
    __block typeof(self) oneself = self;
    
    _baseMovie.completionBlock = ^ {
        [oneself loadSecondTexture];
    };
    
    
    if (!_filter) {
        _filter = [[GPUTwoInputFilter alloc] init];
    }
    
    [_baseMovie addTarget:_filter];
    [_overMovie addTarget:_filter];
    [_filter addTarget:_glView];
    
    [_baseMovie startProcessing];
}

- (void)loadSecondTexture {
    [_overMovie readNextVideoFrame];
}

- (void)startThree {
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    if (!_overMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"trans_1" ofType:@"mp4"]];
        _overMovie = [[GPUMovie alloc] initWithURL:videoURL];
        _overMovie.textureIndex = 1;
        _overMovie.keepLooping = NO;
        [_overMovie startProcessing];
    }
    
    if (!_maskMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"trans_1_mask" ofType:@"mp4"]];
        _maskMovie = [[GPUMovie alloc] initWithURL:videoURL];
        _maskMovie.textureIndex = 2;
        _maskMovie.keepLooping = NO;
        [_maskMovie startProcessing];
    }
    
    __block typeof(self) oneself = self;
    
    _baseMovie.completionBlock = ^ {
        [oneself loadTwoAndThreeTexture];
    };
    
    
    if (!_filter) {
        _filter = [[GPUThreeInputFilter alloc] init];
    }
    
    [_baseMovie addTarget:_filter];
    [_overMovie addTarget:_filter];
    [_maskMovie addTarget:_filter];
    [_filter addTarget:_glView];
    
    [_baseMovie startProcessing];
}

- (void)loadTwoAndThreeTexture {
    [_overMovie readNextVideoFrame];
    [_maskMovie readNextVideoFrame];
}

- (void)startGPUMovie {
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    if (!_overMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"trans_1" ofType:@"mp4"]];
        _overMovie = [[GPUMovie alloc] initWithURL:videoURL];
        _overMovie.textureIndex = 1;
        _overMovie.keepLooping = NO;
        [_overMovie startProcessing];
    }
    
    if (!_maskMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"trans_1_mask" ofType:@"mp4"]];
        _maskMovie = [[GPUMovie alloc] initWithURL:videoURL];
        _maskMovie.keepLooping = NO;
        [_maskMovie startProcessing];
    }
    
    __block typeof(self) oneself = self;
    
    _baseMovie.completionBlock = ^ {
        [oneself reloadBaseTexture];
    };
    
    _overMovie.completionBlock = ^ {
        [oneself reloadOverTexture];
    };
    
    _maskMovie.completionBlock = ^ {
        [oneself reloadMaskTexture];
    };
    
    [_baseMovie startProcessing];
}

- (void)reloadBaseTexture {
    [_overMovie readNextVideoFrame];
    [_maskMovie readNextVideoFrame];
    
    _glView.outputTexture = _baseMovie.outputTexture;
    [_glView draw];
}

- (void)reloadOverTexture {
    _glView.outputTexture2 = _overMovie.outputTexture;
}

- (void)reloadMaskTexture {
//    _glView.maskTexture = _maskMovie.outputTexture;
}

- (void)startRead2 {
    if (!_movie3) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"meiyan_monday" ofType:@"mp4"]];
        _movie3 = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    __block typeof(self) oneself = self;
    
    _movie3.completionBlock = ^ {
        [oneself comletion3];
    };
    
    [_movie3 startProcessing];
}

- (void)comletion3 {
    _glView2.outputTexture = _movie3.outputTexture;
    [_glView2 draw];
}

@end
