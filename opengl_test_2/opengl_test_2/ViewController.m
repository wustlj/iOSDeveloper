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

- (void)drawView:(UIView *)theView
{
//    static const GLfloat triangle[] = {0, 1, -3.0, -1, 0, -3.0, 1, 0, -3.0};
    
    const GLfloat triangle[] = {-0.5, -0.5, -3, 0.5, -0.5, -3, -0.5, 0.5, -3, 0.5, 0.5, -3};
    
    const GLfloat triangleColor[] = {
      1, 0, 0, 1,
      0, 1, 0, 1,
      0, 0, 1, 1,
      1, 1, 0, 1,
    };
    
    glLoadIdentity();
    
//    static GLfloat rot = -45.0;
//    glRotatef(rot, 0, 0, 1);
//    glTranslatef(-1, 0, 0);
//    glScalef(1.5, 1.5, 1);
    

    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glShadeModel(GL_FLAT);
    
//    glColor4f(1.0, 0.0, 0.0, 1.0);
    glVertexPointer(3, GL_FLOAT, 0, triangle);
    glColorPointer(4, GL_FLOAT, 0, triangleColor);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 12);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    //    glDisableClientState(GL_NORMAL_ARRAY);
    
//    static NSTimeInterval lastDrawTime;
//    if (lastDrawTime)
//    {
//        NSTimeInterval timeSinceLastDraw = [NSDate timeIntervalSinceReferenceDate] - lastDrawTime;
//        rot+=50 * timeSinceLastDraw;
//    }
//    lastDrawTime = [NSDate timeIntervalSinceReferenceDate];
//    NSLog(@"%f", rot);
}

-(void)setupView:(UIView*)view
{
	GLfloat size;
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);
	size = kZNear * tanf(DEGREES_TO_RADIANS(kFieldOfView) / 2.0);
	CGRect rect = view.bounds;
    
    //    glOrthox(-1.0, 1.0, -1.0 / (rect.size.width / rect.size.height), 1.0 / (rect.size.width / rect.size.height), 3.0, -3.0);
    
    //投影变换
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size /
			   (rect.size.width / rect.size.height), kZNear, kZFar);
    
    //视口变换
	glViewport(0, 0, rect.size.width, rect.size.height);
    
	glMatrixMode(GL_MODELVIEW);
    
    //    //开启光效
    //    glEnable(GL_LIGHTING);
    //
    //    //打开0光源
    //    glEnable(GL_LIGHT0);
    //
    //    //环境光
    //    const GLfloat light0Ambient[] = {0.1, 0.1, 0.1, 1};
    //    glLightfv(GL_LIGHT0, GL_AMBIENT, light0Ambient);
    //
    //    //散射光
    //    const GLfloat light0Diffuse[] = {0.7, 0.7, 0.7, 1.0};
    //    glLightfv(GL_LIGHT0, GL_DIFFUSE, light0Diffuse);
    //
    //    //高光
    //    const GLfloat light0Specular[] = {0.7, 0.7, 0.7, 1.0};
    //    glLightfv(GL_LIGHT0, GL_SPECULAR, light0Specular);
    //
    //    //光源位置
    //    const GLfloat light0Position[] = {10.0, 10.0, 10.0, 0.0};
    //    glLightfv(GL_LIGHT0, GL_POSITION, light0Position);
    //    
    //    //光源方向
    //    const GLfloat light0Direction[] = {0.0, 0.0, -1.0};
    //    glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, light0Direction);
    //    
    //    //光源角度
    //    glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 45.0);
    
	glLoadIdentity();
}

@end
