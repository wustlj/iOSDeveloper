//
//  ViewController.m
//  opengl_test_4_1
//
//  Created by Kalou on 13-6-24.
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
    
    [self genTexture];
    [self loadTexture];
    
    [self.view addSubview:_glView];
    
    UIButton *rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rotateBtn setFrame:CGRectMake(250, 20, 50, 50)];
    [rotateBtn setTitle:@"rotate" forState:UIControlStateNormal];
    [rotateBtn addTarget:self action:@selector(rotate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rotateBtn];
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


- (void)genTexture {
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)loadTexture {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
        NSLog(@"Do real error checking here");
    
    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width,
                                                 colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( context, 0, height - height );
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, imageData);
    CGContextRelease(context);
    free(imageData);
    [image release];
    [texData release];
}

- (void)drawView:(UIView *)theView {
//    glEnable(GL_CULL_FACE);
/*
    glLoadIdentity();
    
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glShadeModel(GL_SMOOTH);
    GLfloat vertices[] = {
        -0.5f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
         0.5f,  0.5f, 0.0f,
         0.5f, -0.5f, 0.0f,
    };
    
    static const GLfloat texCoords[] = {
        0.0, 1.0,
        1.0, 1.0,
        0.0, 0.0,
        1.0, 0.0
    };
    
    // Load the vertex data
    //
//    GLuint pSlot = _glView.positionSlot;
//    glVertexAttribPointer(pSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
//    glEnableVertexAttribArray(pSlot);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);

//    glColor4f(1.0, 0.0, 0.0, 1.0);
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    // Draw triangle
    //
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
*/

 /*
    const GLfloat squareVertices[] = {
        -0.5f, -0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
         0.5f,  0.5f,  0.5f,
         0.5f, -0.5f,  0.5f,
        
         0.5f, -0.5f, -0.5f,
         0.5f,  0.5f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
    };
    
    GLubyte indies[] = {
        0, 3, 2, 0, 2, 1, // front
        7, 5, 4, 7, 6, 5, // back
        0, 1, 6, 0, 6, 7, // left
        3, 4, 5, 3, 5, 2, // right
        1, 2, 5, 1, 5, 6, // top
        0, 7, 4, 0, 4, 3, // bottom
    };
// ///*
//    const GLbyte indies[] = {
//        0, 1, 3, //front
//        0, 3, 2,
//        5, 4, 6, //back
//        5, 6, 7,
//        4, 0, 2, //left
//        4, 2, 6,
//        1, 5, 7, //right
//        1, 7, 3,
//        2, 3, 7, //top
//        2, 7, 6,
//        4, 5, 1, //bottom
//        4, 1, 0
//    };
//    
    CGFloat colors[] = {
        1.0f, 0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
        
        1.0f, 1.0f, 0.0f, 1.0f,
        1.0f, 0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f,
    };
    
    const GLfloat squareTexCoords[] = {
        0.0, 0.0,
        0.0, 1.0,
        1.0, 1.0,
        1.0, 0.0,
        0.0, 0.0,
        0.0, 1.0,
        1.0, 1.0,
        1.0, 0.0
    };
	GLenum err;
    
    
    GLfloat _scale = 1.0f;
    GLfloat _rotate = 90.0f;
    
    glScalef(_scale, _scale, _scale);
	glTranslatef(0.0f, 0.0f, -2.0f);
	glRotatef(_rotate, 1.0f, 0.0f, 0.0f);
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glColor4f(1.0, 0.0, 0.0, 1.0);
    
    glVertexPointer(3, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
//    glColorPointer(4, GL_FLOAT, 0, colors);
//    glEnableClientState(GL_COLOR_ARRAY);
    
    
    glTexCoordPointer(2, GL_FLOAT, 0, squareTexCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
	glEnable(GL_TEXTURE_2D);
	
	glBindTexture(GL_TEXTURE_2D, texture);
	
    //    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDrawElements(GL_TRIANGLES, sizeof(indies)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indies);
    
	glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
	err = glGetError();
	if (err != GL_NO_ERROR)
		NSLog(@"Error in frame. glError: 0x%04X", err);
  */
    
    CGFloat vertices[] = {
        -0.5, -0.5, -2.0,
           0, -0.5, -2.0,
           0,    0, -2.0,
        -0.5,    0, -2.0,
    };
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    glColor4f(0.0, 1.0, 0.0, 1.0);
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableClientState(GL_VERTEX_ARRAY);
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
    glOrthof(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), -10.0f, 10.0f);
    // glOrthof与glOrthox不同，注意区别。zNear和zFar注意与glFrustumf不同
    
//    glFrustumf(-1.0f, 1.0f, -1.5, 1.5, 1.0f, 10.0f);
    
/*
     //投影变换
     size = kZNear * tanf(DEGREES_TO_RADIANS(kFieldOfView) / 2.0);
     glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), kZNear, kZFar);
*/
    
	glMatrixMode(GL_MODELVIEW);
    
	glLoadIdentity();
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
