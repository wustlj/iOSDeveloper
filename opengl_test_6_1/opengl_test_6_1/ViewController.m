//
//  ViewController.m
//  opengl_test_6
//
//  Created by lijian on 13-7-18.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    GLuint texture;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    _glView = [[OpenGLView alloc] initWithFrame:SCREEN_BOUND];
    _glView.delegate = self;
    
    [self.view addSubview:_glView];
    
    UIButton *rotateBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rotateBtn setFrame:CGRectMake(220, 0, 100, 50)];
    [rotateBtn setTitle:@"change VBO" forState:UIControlStateNormal];
    [rotateBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [rotateBtn addTarget:self action:@selector(rotate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rotateBtn];
}

- (void)rotate:(id)sender {
    [_glView toggleDisplayLink];
}

-(void)setupView:(UIView*)view
{
	GLfloat size;
	CGRect rect = view.bounds;
    
	glEnable(GL_DEPTH_TEST);
    
    //视口变换
	glViewport(0, 0, rect.size.width, rect.size.height);
    
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    //正交变换
    size = 1.0f;
//    glOrthof(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), -10.0f, 10.0f);
    // glOrthof与glOrthox不同，注意区别。zNear和zFar注意与glFrustumf不同
    
    //    glFrustumf(-1.0f, 1.0f, -1.5, 1.5, 1.0f, 10.0f);
    
///*
    //投影变换
    size = kZNear * tanf(DEGREES_TO_RADIANS(kFieldOfView) / 2.0);
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), kZNear, kZFar);
// */
    
    //	glMatrixMode(GL_MODELVIEW);
    //
    //	glLoadIdentity();
    glClearColor(0.0f,0.0f,0.0f,0.0f);  //黑色
    
}

- (void)drawView:(UIView *)theView {
    
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