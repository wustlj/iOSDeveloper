//
//  ViewController.m
//  opengl_test_3
//
//  Created by Kalou on 13-6-8.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _boundFrame = [[UIScreen mainScreen] bounds];
    _openGLView = [[OpenGLView alloc] initWithFrame:_boundFrame];
    _openGLView.delegate = self;
    [self.view addSubview:_openGLView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawView:(UIView *)theView
{
    
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
    glOrthof(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), -5, 5);
    // glOrthof与glOrthox不同，注意区别。zNear和zFar注意与glFrustumf不同
    
/*
    //投影变换
    size = kZNear * tanf(DEGREES_TO_RADIANS(kFieldOfView) / 2.0);
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), kZNear, kZFar);
*/
    
	glMatrixMode(GL_MODELVIEW);
    
	glLoadIdentity();
}

@end
