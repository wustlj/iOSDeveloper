//
//  ViewController.m
//  GLES2.1
//
//  Created by lijian on 14-2-21.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _glView = [[GLView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_glView];
    
    [_glView release];
    
    [_glView startAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
