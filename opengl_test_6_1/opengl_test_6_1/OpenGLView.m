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

#define Z_ANGLE 45.0f
#define CURVE_FACE_NUM 11 

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface OpenGLView ()
{
    GLfloat curveVertices[CURVE_FACE_NUM*3*4*2];
    GLfloat curveTextureCoords[CURVE_FACE_NUM*2*4*2];
    
    GLuint vertexBuffer;

}
@property (nonatomic, retain) EAGLContext *context;
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)setupProgram;
@end


@implementation OpenGLView

@synthesize context;
@synthesize delegate;
@synthesize positionSlot = _positionSlot;
@synthesize rotate = _rotate;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        [self setupLayer];
        [self setupContext];
        [self genTexture];
        [self loadTexture];
        _rotate = 0.0f;
//        [self setupProgram];
        [self createVBO];
    }
    return self;
}

- (void)dealloc {
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    [self destroyFramebuffer];
    [self destroyVBO];
    
    [context release];
    [super dealloc];
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    
    [delegate setupView:self];
    
    [self drawView];
}

#pragma mark - Setup

- (void)setupLayer {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
//    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
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

#pragma mark - Texture

- (void)genTexture {
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)loadTexture {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Brick" ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
        NSLog(@"Do real error checking here");
    
    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef contextRef = CGBitmapContextCreate( imageData, width, height, 8, 4 * width,
                                                 colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( contextRef, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( contextRef, 0, height - height );
    CGContextDrawImage( contextRef, CGRectMake( 0, 0, width, height ), image.CGImage );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, imageData);
    CGContextRelease(contextRef);
    free(imageData);
    [image release];
    [texData release];
}

#pragma mark - Frame buffer

- (BOOL)createFramebuffer {
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (1) {
		
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    return YES;
}

- (void)destroyFramebuffer {
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)createVBO {
    const GLfloat vertices[] = {
        -1.0, -1.0, -5.0,
        1.0, -1.0, -5.0,
        1.0,  1.0, -5.0,
    };
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 9*sizeof(GLfloat), vertices, GL_STATIC_DRAW);
}

- (void)destroyVBO {
    if (vertexBuffer) {
        glDeleteBuffers(1, &vertexBuffer);
        vertexBuffer = 0;
    }
}

#pragma mark - Draw

- (void)drawView
{
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    [self render];
    
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)render {
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);
    
    glLoadIdentity();
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, NULL);
    
    glColor4f(1.0, 0, 0, 1.0);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

#pragma mark - DisplayLink

- (void)toggleDisplayLink {
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);

    GLvoid *bufferData = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    if (bufferData == NULL) {
        glUnmapBufferOES(GL_ARRAY_BUFFER);
        return;
    }
    
    const GLfloat vertices[] = {
        -1.0, -1.0, -5.0,
         1.0, -1.0, -5.0,
        -1.0,  1.0, -5.0,
    };
    memcpy(bufferData, vertices, sizeof(vertices));
    
    glUnmapBufferOES(GL_ARRAY_BUFFER);
    
    [self setNeedsLayout];
}

@end
