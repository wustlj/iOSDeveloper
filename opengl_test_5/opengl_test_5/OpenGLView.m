//
//  OpenGLView.m
//  opengl_test_1
//
//  Created by Kalou on 13-5-12.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import "OpenGLView.h"
#import <QuartzCore/QuartzCore.h>
#import "GLESUtils.h"

@interface OpenGLView ()
@property (nonatomic, retain) EAGLContext *context;
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)setupProgram;
@end


@implementation OpenGLView

@synthesize context;
@synthesize delegate;
@synthesize positionSlot = _positionSlot;
@synthesize rotateShould = _rotateShould;
@synthesize rotateElbow = _rotateElbow;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        [self setupLayer];
        [self setupContext];
        [self setupProgram];
        [self setupProjection];
        
        self.rotateShould = 0.0f;
        self.rotateElbow = 0.0f;
    }
    return self;
}

- (void)setRotateElbow:(float)rotateElbow {
    _rotateElbow = rotateElbow;
    
    [self render];
}

- (void)setRotateShould:(float)rotateShould {
    _rotateShould = rotateShould;
    
    [self render];
}

- (void)setupLayer {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (context == NULL)
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
        }
    }

    [EAGLContext setCurrentContext:context];
}

- (void)setupProgram {
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    
    GLuint vertexShader = [GLESUtils loadShader:GL_VERTEX_SHADER withFilepath:vertexShaderPath];
    GLuint fragmentShader = [GLESUtils loadShader:GL_FRAGMENT_SHADER withFilepath:fragmentShaderPath];
    
    _programHandle = glCreateProgram();
    if (!_programHandle) {
        NSLog(@"create program fail");
        return;
    }
    
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    
    glLinkProgram(_programHandle);
    
    GLint linked;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv (_programHandle, GL_INFO_LOG_LENGTH, &infoLen );
        
        if (infoLen > 1)
        {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog (_programHandle, infoLen, NULL, infoLog );
            NSLog(@"Error linking program:\n%s\n", infoLog );
            
            free (infoLog );
        }
        
        glDeleteProgram(_programHandle);
        _programHandle = 0;
        return;
    }
    glUseProgram(_programHandle);
    
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    _colorSlot = glGetAttribLocation(_programHandle, "vSourceColor");
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    _projectSlot = glGetUniformLocation(_programHandle, "projection");
}

- (void)setupProjection {
    float aspect = self.frame.size.width / self.frame.size.height;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 60.0, aspect, 1.0f, 20.0f);
    
    // Load projection matrix
    glUniformMatrix4fv(_projectSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    glEnable(GL_CULL_FACE);
}

- (void)drawView
{
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    [self render];
}

- (void)layoutSubviews
{
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

- (BOOL)createFramebuffer
{
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
        
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    [delegate setupView:self];
    return YES;
}

- (void)destroyFramebuffer
{
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
}

- (void)dealloc
{    
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    [super dealloc];
}

- (void)updateShoulderTransform {
    ksMatrixLoadIdentity(&_shouldModelViewMatrix);
    ksMatrixTranslate(&_shouldModelViewMatrix, 0.0, 0.0, -5.5);
    ksMatrixRotate(&_shouldModelViewMatrix, self.rotateShould, 0.0, 0.0, 1.0);
    
    ksMatrixCopy(&_modelViewMatrix, &_shouldModelViewMatrix);
    ksMatrixScale(&_modelViewMatrix, 1.5, 0.6, 0.6);
 
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
}

- (void)updateElbowTransform {
    ksMatrixCopy(&_elbowModelViewMatrix, &_shouldModelViewMatrix);
    ksMatrixTranslate(&_elbowModelViewMatrix, 1.5, 0.0, 0.0);
    ksMatrixRotate(&_elbowModelViewMatrix, self.rotateElbow, 0.0, 0.0, 1.0);
    
    ksMatrixCopy(&_modelViewMatrix, &_elbowModelViewMatrix);
    ksMatrixScale(&_modelViewMatrix, 1.0, 0.4, 0.4);
    
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
}

- (void)drawCube:(ksColor)color {
    GLfloat vertices[] = {
        0.0f, -0.5f, 0.5f,
        0.0f, 0.5f, 0.5f,
        1.0f, 0.5f, 0.5f,
        1.0f, -0.5f, 0.5f,
        
        1.0f, -0.5f, -0.5f,
        1.0f, 0.5f, -0.5f,
        0.0f, 0.5f, -0.5f,
        0.0f, -0.5f, -0.5f,
    };
    
    GLubyte indices[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 5, 5, 6, 6, 7, 7, 4,
        0, 7, 1, 6, 2, 5, 3, 4
    };
    
    glVertexAttrib4f(_colorSlot, color.r, color.g, color.b, color.a);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
}

- (void)render {
    [delegate setupView:self];
    
    ksColor colorRed = {1.0, 0.0, 0.0, 1.0};
    ksColor colorBlue = {0.0, 0.0, 1.0, 1.0};
    
    [self updateShoulderTransform];
    [self drawCube:colorRed];
    
    [self updateElbowTransform];
    [self drawCube:colorBlue];
    
    [self updateColorCubeTransform];
    [self drawColorCube];
    
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)drawColorCube {
    CGFloat vertices[] = {
        -0.5f, -0.5f,  0.5f, 1.0f, 0.0f, 0.0f, 1.0f,
        -0.5f,  0.5f,  0.5f, 1.0f, 1.0f, 0.0f, 1.0f,
         0.5f,  0.5f,  0.5f, 0.0f, 0.0f, 1.0f, 1.0f,
         0.5f, -0.5f,  0.5f, 1.0f, 1.0f, 1.0f, 1.0f,
        
         0.5f, -0.5f, -0.5f, 1.0f, 1.0f, 0.0f, 1.0f,
         0.5f,  0.5f, -0.5f, 1.0f, 0.0f, 0.0f, 1.0f,
        -0.5f,  0.5f, -0.5f, 1.0f, 1.0f, 1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f, 0.0f, 0.0f, 1.0f, 1.0f,
    };
    
    GLubyte indices[] = {
        0, 3, 2, 0, 2, 1, // front
        7, 5, 4, 7, 6, 5, // back
        0, 1, 6, 0, 6, 7, // left
        3, 4, 5, 3, 5, 2, // right
        1, 2, 5, 1, 5, 6, // top
        0, 7, 4, 0, 4, 3, // bottom
    };
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices);
    glVertexAttribPointer(_colorSlot, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices + 3);
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
    
    glDisableVertexAttribArray(_colorSlot);
}

- (void)updateColorCubeTransform {
    ksMatrixLoadIdentity(&_colorCubeModelViewMatrix);
    ksMatrixTranslate(&_colorCubeModelViewMatrix, 0.0, -2.0, -5.5);
    ksMatrixRotate(&_colorCubeModelViewMatrix, _rotateColorCube, 0.0, 1.0, 0.0);
        
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_colorCubeModelViewMatrix.m[0][0]);
}

- (void)toggleDisplayLink {
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallBack:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    } else {
        [_displayLink invalidate];
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
}

- (void)displayLinkCallBack:(CADisplayLink*)displayLink
{
    NSLog(@"%f", displayLink.duration);
    _rotateColorCube += displayLink.duration * 90;
    NSLog(@"%f", _rotateColorCube);
    
    [self render];
}

@end
