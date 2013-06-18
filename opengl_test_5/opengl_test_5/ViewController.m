//
//  ViewController.m
//  opengl_test_5
//
//  Created by Kalou on 13-6-18.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)dealloc {
    [_glView release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _glView = [[OpenGLView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _glView.delegate = self;
    [self.view addSubview:_glView];
    
    UISlider *silder1 = [[UISlider alloc] initWithFrame:CGRectMake(18, 20, 205, 23)];
    silder1.maximumValue = 360.0f;
    silder1.minimumValue = 0.0f;
    [silder1 addTarget:self action:@selector(shoulderRotateAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:silder1];

    UISlider *silder2 = [[UISlider alloc] initWithFrame:CGRectMake(18, 70, 205, 23)];
    silder2.maximumValue = 360.0f;
    silder2.minimumValue = 0.0f;
    [silder2 addTarget:self action:@selector(belowRotateAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:silder2];
    
    UIButton *rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rotateBtn setFrame:CGRectMake(250, 20, 50, 50)];
    [rotateBtn setTitle:@"rotate" forState:UIControlStateNormal];
    [rotateBtn addTarget:self action:@selector(rotate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rotateBtn];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (void)shoulderRotateAction:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    _glView.rotateShould = currentValue;
}

- (void)belowRotateAction:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    _glView.rotateElbow = currentValue;
}

- (void)rotate:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if ([btn.titleLabel.text isEqualToString:@"rotate"]) {
        [btn setTitle:@"stop" forState:UIControlStateNormal];
    } else {
        [btn setTitle:@"rotate" forState:UIControlStateNormal];
    }
    
    [_glView toggleDisplayLink];
}

#pragma mark - OpenGLViewDelegate

- (void)drawView:(UIView *)theView {
    
}

- (void)setupView:(UIView *)theView {
    glClearColor(0.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGRect bound = [[UIScreen mainScreen] bounds];
    glViewport(0, 0, bound.size.width, bound.size.height);
}


@end
