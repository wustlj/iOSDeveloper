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

@interface ViewController ()
{
    GPUView *_glView;
    GPUView *_glView2;
    
    GPUMovie *_movie1;
    GPUMovie *_movie2;
    GPUMovie *_movie3;
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
    [btn setFrame:CGRectMake(0, 400, 100, 50)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"Begin" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startGPUMovie) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setFrame:CGRectMake(0, 500, 100, 50)];
    [btn2 setBackgroundColor:[UIColor redColor]];
    [btn2 setTitle:@"Begin" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(startRead2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

#pragma mark - Action

- (void)startGPUMovie {
    if (!_movie1) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480" ofType:@"mp4"]];
        _movie1 = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    if (!_movie2) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"PTstar" ofType:@"mp4"]];
        _movie2 = [[GPUMovie alloc] initWithURL:videoURL];
        _movie2.keepLooping = NO;
        [_movie2 startProcessing];
    }
    
    __block typeof(self) oneself = self;
    
    _movie1.completionBlock = ^ {
        [oneself reloadView1];
    };
    
    _movie2.completionBlock = ^ {
        [oneself reloadView2];
    };
    
    [_movie1 startProcessing];
}

- (void)reloadView1 {
    [_movie2 readNextVideoFrame];
    
    _glView.outputTexture = _movie1.outputTexture;
    [_glView draw];
}

- (void)reloadView2 {
    _glView.outputTexture2 = _movie2.outputTexture;
}

- (void)startRead2 {
    if (!_movie3) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"end_meiyan_cn" ofType:@"mp4"]];
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
