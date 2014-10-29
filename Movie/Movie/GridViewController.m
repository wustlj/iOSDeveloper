//
//  GridViewController.m
//  Movie
//
//  Created by lijian on 14-10-29.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController ()

@end

@implementation GridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_glView release];
    [_baseMovie release];
    [_filter release];
    
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
    
    _glView = [[GPUView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn.frame), 320, 320)];
    [self.view addSubview:_glView];
    [_glView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startAction
{
    if (!_baseMovie) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480_2" ofType:@"mp4"]];
        _baseMovie = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    if (!_filter) {
        _filter = [[GPUGridFilter alloc] init];
    }
    
    [_baseMovie addTarget:_filter];
    [_filter addTarget:_glView];
    
    [_baseMovie startProcessing];
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
