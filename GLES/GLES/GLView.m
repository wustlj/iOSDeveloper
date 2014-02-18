//
//  GLView.m
//  GLES
//
//  Created by lijian on 14-2-14.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GLView.h"

@implementation GLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _angle = 0.0;

        [self setupLayer];
        [self setupContext];
        [self setupTexture];
        [self setupProject];
    }
    return self;
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                     kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    
    if ([EAGLContext currentContext] != _context) {
        [EAGLContext setCurrentContext:_context];
    }
}

- (void)setupRenderBuffer {
    glGenBuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    glGenRenderbuffers(1, &_depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
}

- (void)setupFrameBuffer {
    glGenBuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"framebuffer status error");
    }
}

- (void)destoryRenderAndFrameBuffer {
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    if (_depthBuffer) {
        glDeleteRenderbuffers(1, &_depthBuffer);
        _depthBuffer = 0;
    }
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

- (void)setupProject {
    CGRect rect = self.bounds;
    GLfloat size = 1.0f;
    
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
    glViewport(0, 0, rect.size.width, rect.size.height);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), -5, 5);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

- (void)layoutSubviews {
    [self destoryRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    glBindRenderbuffer(GL_FRAMEBUFFER, _frameBuffer);
    [self renderCube];
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)renderCube {
    glLoadIdentity();

    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glShadeModel(GL_FLAT);
    
    static const GLfloat vertices[] = {
        -1, -1,  1,
        -1,  1,  1,
         1,  1,  1,
         1, -1,  1,
         1, -1, -1,
         1,  1, -1,
        -1,  1, -1,
        -1, -1, -1,
    };
    
    static const GLfloat colors[] = {
        1.0, 0.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        1.0, 0.0, 1.0, 1.0,
        0.0, 1.0, 1.0, 1.0,
        0.0, 0.0, 0.0, 1.0,
        1.0, 1.0, 1.0, 1.0,
    };
    
    static const GLuint indices[] = {
        0, 3, 2, 0, 2, 1, // front
        7, 5, 4, 7, 6, 5, // back
        0, 1, 6, 0, 6, 7, // left
        3, 4, 5, 3, 5, 2, // right
    };
    
    static const GLuint indices2[] = {
        1, 2, 5, 1, 5, 6, // top
        0, 7, 4, 0, 4, 3, // bottom
    };
    
    static const GLfloat texCoord[] = {
        0.0, 0.0,
        1.0, 0.0,
        1.0, 1.0,
        0.0, 1.0,
        0.0, 0.0,
        1.0, 0.0,
        1.0, 1.0,
        0.0, 1.0,
    };
    
    static const GLfloat texCoord2[] = {
        0.0, 0.0,
        1.0, 0.0,
        1.0, 1.0,
        0.0, 1.0,
        1.0, 0.0,
        0.0, 0.0,
        0.0, 1.0,
        1.0, 1.0,
    };
    
    glRotatef(_angle, 1, 1, 1);
    glScalef(0.5, 0.5, 0.5);
    
    glColorPointer(4, GL_FLOAT, 0, colors);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoord);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(GLuint), GL_UNSIGNED_INT, indices);
    
    glTexCoordPointer(2, GL_FLOAT, 0, texCoord2);
    glDrawElements(GL_TRIANGLES, sizeof(indices2)/sizeof(GLuint), GL_UNSIGNED_INT, indices2);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)render {
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glShadeModel(GL_SMOOTH);
    
    static const GLfloat vertices[] = {
        -1.0, -1.0, -1.0,
         1.0, -1.0, -1.0,
         1.0,  1.0, -1.0,
        -1.0,  1.0, -1.0,
    };
    
    static const GLfloat texCoord[] = {
        0.0, 0.0,
        1.0, 0.0,
        1.0, 1.0,
        0.0, 1.0,
    };
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoord);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)setupTexture {
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ZERO);
    
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    [self loadImage];
}

- (void)loadImage {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"512" ofType:@"png"];
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
    CGContextTranslateCTM (context, 0, height);
    CGContextScaleCTM (context, 1.0, -1.0);
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(context);
    
    free(imageData);
    [image release];
    [texData release];
}

- (void)startAnimation {
    if (nil == _displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)stopAnimation {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink {
    _angle += displayLink.duration * 90;
    [self renderCube];
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)dealloc {
    [self stopAnimation];
    
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    if (_depthBuffer) {
        glDeleteRenderbuffers(1, &_depthBuffer);
        _renderBuffer = 0;
    }
    
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [_context release];
    _context = nil;
    
    [super dealloc];
}

@end
