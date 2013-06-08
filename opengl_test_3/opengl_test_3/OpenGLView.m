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

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        [self setupLayer];
        [self setupContext];
        [self setupProgram];
    }
    return self;
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
}

- (void)drawView
{
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    [delegate drawView:self];
    
    [self render];
    
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)render {
    glLoadIdentity();
    
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f };
    
    // Load the vertex data
    //
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw triangle
    //
    glDrawArrays(GL_TRIANGLES, 0, 3);
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

@end
