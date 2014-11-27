//
//  MVViewController.m
//  Movie
//
//  Created by lijian on 14/11/24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "MVViewController.h"

#import "GPUMV.h"

@interface MVViewController ()
{
    GPUMV *_gpuMV;
}
@end

@implementation MVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 64, 120, 50)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"Start" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)startAction {
    if (!_gpuMV) {
        NSMutableArray *movies = [[NSMutableArray alloc] init];
        [movies addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480" ofType:@"mp4"]]];
        [movies addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]]];
        [movies addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_3" ofType:@"mp4"]]];
        _gpuMV = [[GPUMV alloc] initWithMovies:movies];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
    [_gpuMV loadMV:path];
}

@end
