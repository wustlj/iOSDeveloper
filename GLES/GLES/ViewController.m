//
//  ViewController.m
//  GLES
//
//  Created by lijian on 14-2-14.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!_glView) {
        _glView = [[GLView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    [self.view addSubview:_glView];
    
    [_glView startAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_glView release];
    
    [super dealloc];
}

@end
