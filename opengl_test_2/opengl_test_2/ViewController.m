//
//  ViewController.m
//  opengl_test_2
//
//  Created by Kalou on 13-5-13.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <OpenGLViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

- (void)dealloc {
    [_openGLView release];
    
    [super dealloc];
}

- (void)drawView:(UIView *)theView {
    glLoadIdentity();
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glEnableClientState(GL_VERTEX_ARRAY);

    glColor4f(1.0, 1.0, 0, 1.0);
    GLfloat triangle[] = {0, 1, -3, -1, 0, -3, 1, 0, -3};
    glVertexPointer(3, GL_FLOAT, 0, triangle);
    glDrawArrays(GL_TRIANGLES, 0, 9);
    glDisableClientState(GL_VERTEX_ARRAY);
}

-(void)setupView:(UIView*)view
{

	const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0;
	GLfloat size;
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
    NSLog(@"%f", size);
	CGRect rect = view.bounds;
    
//    glOrthox(-1.0, 1.0, -1.0 / (rect.size.width / rect.size.height), 1.0 / (rect.size.width / rect.size.height), 3.0, -3.0);

//    glOrthof(-3.0f, 3.0f, -3.0f, 3.0f, -zNear, -zFar);

    //视口变换
	glViewport(0, 0, rect.size.width, rect.size.height);
	
    //投影变换
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size /
			   (rect.size.width / rect.size.height), zNear, zFar);
    
	glMatrixMode(GL_MODELVIEW);
    
	glLoadIdentity();
}

@end
