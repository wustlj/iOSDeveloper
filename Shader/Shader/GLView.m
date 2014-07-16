//
//  GLView.m
//  Shader
//
//  Created by lijian on 14-7-7.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GLView.h"

#import "matrix.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

#define VERTEX_WIDTH 0.5f

NSString *const kVertexShaderString = SHADER_STRING
(
 attribute vec4 vPosition;
 attribute vec4 color;
 attribute vec2 textureCoord;
 
 uniform mat4 modelViewMat;
 uniform mat4 projectMat;
 
 varying vec4 colorVarying;
 varying vec2 textureCoordOut;
 
 void main()
 {
    gl_Position = projectMat * modelViewMat * vPosition;
    colorVarying = color;
    textureCoordOut = textureCoord;
 }
);



NSString *const kFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 
 varying vec4 colorVarying;
 varying vec2 textureCoordOut;
 
 uniform sampler2D sampler;
 
 void main()
 {
     vec4 c = texture2D(sampler, textureCoordOut);
     gl_FragColor = c;
 }
);


@implementation GLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        
        [GPUContext useImageProcessingContext];
        
        GLProgram *program = [[GPUContext sharedImageProcessingContext] programForVertexShaderString:kVertexShaderString fragmentShaderString:kFragmentShaderString];
        
        [program link];
        
        [GPUContext setActiveShaderProgram:program];
        
        _positionSlot = [program attributeSlot:@"vPosition"];
        _textureSlot = [program attributeSlot:@"textureCoord"];
        _colorSlot = [program attributeSlot:@"color"];
        _modelViewSlot = [program uniformIndex:@"modelViewMat"];
        _projectSlot = [program uniformIndex:@"projectMat"];
        _samplerSlot = [program uniformIndex:@"sampler"];
    }
    return self;
}

- (void)dealloc {
    [self destoryFBO];
    
    [super dealloc];
}

- (void)layoutSubviews {
    [self destoryFBO];
    [self createFBO];
    [self draw];
}

- (void)draw {
    const GLfloat vertex[] = {
        -0.5, -0.5, 0.5,
         0.5, -0.5, 0.5,
         0.5,  0.5, 0.5,
        -0.5,  0.5, 0.5,
    };
    
    const GLfloat texCoord[] = {
        0.0, 0.0,
        1.0, 0.0,
        1.0, 1.0,
        0.0, 1.0,
    };
    
    const GLubyte colors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
    GLfloat modelViewMat[16], projectMat[16];
    
    mat4f_LoadIdentity(projectMat);
    mat4f_LoadIdentity(modelViewMat);
    
    mat4f_LoadOrtho(-1.0f, 1.0f, -1.5f, 1.5f, -5.0f, 5.0f, projectMat);
//    mat4f_LoadRotation(modelViewMat, 0, 1, 0, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glEnable(GL_CULL_FACE);
    
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertex);
    glEnableVertexAttribArray(_positionSlot);
    
    glVertexAttribPointer(_textureSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoord);
    glEnableVertexAttribArray(_textureSlot);
    
    glVertexAttribPointer(_colorSlot, 4, GL_UNSIGNED_BYTE, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(_colorSlot);
    
    glUniformMatrix4fv(_modelViewSlot, 1, 0, modelViewMat);
    glUniformMatrix4fv(_projectSlot, 1, 0, projectMat);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _outputTexture);
    glUniform1i(_samplerSlot, 1);
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [[[GPUContext sharedImageProcessingContext] context] presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                     kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)createFBO {
    [self initializeOutputTexture];
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);

    [[[GPUContext sharedImageProcessingContext] context] renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
//    glBindTexture(GL_TEXTURE_2D, _outputTexture);
//    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.frame.size.width, self.frame.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
//    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _outputTexture, 0);
    
    glGenRenderbuffers(1, &_depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)initializeOutputTexture {
    if (!_outputTexture) {
        glGenTextures(1, &_outputTexture);
        glBindTexture(GL_TEXTURE_2D, _outputTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        [self loadImage];
        
        glBindTexture(GL_TEXTURE_2D, 0);
    }
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

- (void)destoryFBO {
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_outputTexture) {
        glDeleteTextures(1, &_outputTexture);
        _outputTexture = 0;
    }
    
    if (_depthBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    if (_depthBuffer) {
        glDeleteRenderbuffers(1, &_depthBuffer);
        _depthBuffer = 0;
    }
}

@end
