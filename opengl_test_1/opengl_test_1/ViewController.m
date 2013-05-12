//
//  ViewController.m
//  opengl_test_1
//
//  Created by Kalou on 13-5-12.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect boundFrame = [[UIScreen mainScreen] bounds];
    _glView = [[OpenGLView alloc] initWithFrame:boundFrame];
    [self.view addSubview:_glView];
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
