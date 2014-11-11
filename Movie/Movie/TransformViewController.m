//
//  TransformViewController.m
//  Movie
//
//  Created by lijian on 14-10-29.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "TransformViewController.h"

@interface TransformViewController ()

@end

@implementation TransformViewController

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
    
    UISlider *silder = [[UISlider alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_glView.frame), 320, 30)];
    silder.minimumValue = 0;
    silder.maximumValue = 360;
    [silder addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:silder];
    [silder release];
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
        _filter = [[GPUTransformFilter alloc] init];
    }
    
    [_baseMovie addTarget:_filter];
    [_filter addTarget:_glView];
    
    [_baseMovie startProcessing];
}

- (void)valueChanged:(id)sender {
    UISlider *silder = (UISlider *)sender;
    GPUTransformFilter *filter = (GPUTransformFilter *)_filter;
    
    [filter setTransform3D:CATransform3DMakeRotation(degreesToRadian([silder value]), 0, 1, 0)];
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
