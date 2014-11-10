//
//  ImageViewController.m
//  Movie
//
//  Created by lijian on 14/11/6.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

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
    [_glView release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)startAction
{
    if (!_baseImage) {
        UIImage *image = [UIImage imageNamed:@"WID-small.jpg"];
        _baseImage = [[GPUImage alloc] initWithImage:image];
    }
    
    [_baseImage addTarget:_glView];
    
    [_baseImage processImage];
}

@end
