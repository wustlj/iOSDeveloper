//
//  GLView.m
//  GLES2.0
//
//  Created by lijian on 14-2-18.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GLView.h"

#define degreesToRadian(x) (M_PI * x / 180.0)

@implementation GLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        rotDegree = 0; //degreesToRadian(90);
        [self setupLayer];
        [self setupContext];
        if (![self loadShaders]) {
            NSLog(@"load shader fail");
        }
        [self setupTexture];
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
    if (nil == _context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    if ([EAGLContext currentContext] != _context) {
        [EAGLContext setCurrentContext:_context];
    }
}

- (void)createRenderBuffer {
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    
#warning Gen depth buffer must after get renderbuffer width and height
    glGenRenderbuffers(1, &_depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
}

- (void)createFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)destoryFrameBufferAndRenderBuffer {
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    if (_depthBuffer) {
        glDeleteRenderbuffers(1, &_depthBuffer);
        _depthBuffer = 0;
    }
    if (_frameBuffer) {
        glDeleteRenderbuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

- (BOOL)loadShaders {
    GLuint vertexShader = 0, fragmentShader = 0;
    NSString *vertexPath, *fragmentPath;
    
    _program = glCreateProgram();
    
    vertexPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@"vsh"];
    fragmentPath = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@"fsh"];
    
    if (!compileShader(&vertexShader, GL_VERTEX_SHADER, 1, vertexPath)) {
        destroyShaders(vertexShader, fragmentShader, _program);
        return NO;
    }
    
    if (!compileShader(&fragmentShader, GL_FRAGMENT_SHADER, 1, fragmentPath)) {
        destroyShaders(vertexShader, fragmentShader, _program);
        return NO;
    }
    
    glAttachShader(_program, vertexShader);
    glAttachShader(_program, fragmentShader);
    
    if (!linkProgram(_program)) {
        destroyShaders(vertexShader, fragmentShader, _program);
        return NO;
    }
    
    if (vertexShader) {
        glDeleteShader(vertexShader);
        vertexShader = 0;
    }
    if (fragmentShader) {
        glDeleteShader(fragmentShader);
        fragmentShader = 0;
    }
    
    _positionSlot = glGetAttribLocation(_program, "position");
    _colorSlot = glGetAttribLocation(_program, "color");
    _modelViewSlot = glGetUniformLocation(_program, "modelViewMatrix");
    _projectSlot = glGetUniformLocation(_program, "projectMatrix");
    _textureSlot = glGetAttribLocation(_program, "textureCoord");
    _samplerSlot = glGetUniformLocation(_program, "Sampler");
    
    return YES;
}

- (void)layoutSubviews {
    [self destoryFrameBufferAndRenderBuffer];
    [self createRenderBuffer];
    [self createFrameBuffer];
    [self render];
}

- (void)render {
    [EAGLContext setCurrentContext:_context];
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, _width, _height);
    glEnable(GL_CULL_FACE);
    
    const GLfloat vertices[] = {
        -0.5, -0.5,  0.5,
        -0.5,  0.5,  0.5,
         0.5,  0.5,  0.5,
         0.5, -0.5,  0.5,
        
         0.5, -0.5, -0.5,
         0.5,  0.5, -0.5,
        -0.5,  0.5, -0.5,
        -0.5, -0.5, -0.5,
        
        -0.5, -0.5, -0.5,
        -0.5,  0.5, -0.5,
        -0.5,  0.5,  0.5,
        -0.5, -0.5,  0.5,
        
         0.5, -0.5,  0.5,
         0.5,  0.5,  0.5,
         0.5,  0.5, -0.5,
         0.5, -0.5, -0.5,
        
        -0.5,  0.5,  0.5,
        -0.5,  0.5, -0.5,
         0.5,  0.5, -0.5,
         0.5,  0.5,  0.5,

        -0.5, -0.5, -0.5,
        -0.5, -0.5,  0.5,
         0.5, -0.5,  0.5,
         0.5, -0.5, -0.5,
    };
    
    const GLubyte colors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
        
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
        
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
        
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
        
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
        
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
    const GLuint indices[] = {
        0,3,2,0,2,1, // front
        4,7,6,4,6,5, // back
        11,10,8,8,10,9, // right
        12,15,13,15,14,13, // left
        16,18,17,16,19,18, // top
        20,23,22,20,22,21, // bottom
    };
    
    const GLfloat texCoord[] = {
        0, 0,
        0, 1,
        1, 1,
        1, 0,
        
        1, 0,
        1, 1,
        0, 1,
        0, 0,
        
        0, 0,
        0, 1,
        1, 1,
        1, 0,
        0, 1,
        0, 0,
        1, 0,
        1, 1,
        0, 0,
        1, 0,
        1, 1,
        0, 1,
        0, 0,
        0, 1,
        1, 1,
        1, 0,
    };
    
    GLfloat modelViewMatrix[16], projectMatrix[16];
    
    mat4f_LoadIdentity(projectMatrix);
    mat4f_LoadIdentity(modelViewMatrix);
    mat4f_LoadOrtho(-1.0f, 1.0f, -1.5f, 1.5f, -5.0f, 5.0f, projectMatrix);
    mat4f_LoadRotation(modelViewMatrix, rotDegree, 1, 1, 1);
    
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(_program);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_colorSlot, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, colors);
    glEnableVertexAttribArray(_colorSlot);
    glVertexAttribPointer(_textureSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoord);
    glEnableVertexAttribArray(_textureSlot);
    glActiveTexture(GL_TEXTURE0);
    glUniform1i(_samplerSlot, 0);
    glUniformMatrix4fv(_modelViewSlot, 1, 0, modelViewMatrix);
    glUniformMatrix4fv(_projectSlot, 1, 0, projectMatrix);
    
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(GLuint), GL_UNSIGNED_INT, indices);
    
    glDisableVertexAttribArray(_positionSlot);
    glDisableVertexAttribArray(_colorSlot);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupTexture {
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ZERO);
    
    glGenTextures(1, &_texture1);
    glBindTexture(GL_TEXTURE_2D, _texture1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    [self loadImage:[[NSBundle mainBundle] pathForResource:@"512" ofType:@"png"]];
}

- (void)loadImage:(NSString *)path {
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

- (void)dealloc {
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
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    if (_texture1) {
        glDeleteTextures(1, &_texture1);
        _texture1 = 0;
    }
    
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [_context release];
    _context = nil;
    
    [super dealloc];
}

- (void)startAnimation {
    if (nil == _link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderAnimation:)];
        [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    } else {
        [_link invalidate];
        _link = nil;
    }
}

- (void)renderAnimation:(CADisplayLink *)link {
    rotDegree += link.duration * 90;
    [self render];
}

@end
