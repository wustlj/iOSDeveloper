//
//  GLView.m
//  Shader
//
//  Created by lijian on 14-7-7.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUView.h"

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
 
 uniform mat4 modelViewMatrix;
 uniform mat4 projectMatrix;
 
 varying vec4 colorVarying;
 varying vec2 textureCoordOut;
 
 void main()
 {
    gl_Position = vPosition;
    colorVarying = color;
    textureCoordOut = textureCoord;
 }
);

NSString *const kGPUImagePassthroughFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordOut;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordOut);
 }
 );

@implementation GPUView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        
        [GPUContext useImageProcessingContext];
        
        program = [[[GPUContext sharedImageProcessingContext] programForVertexShaderString:kVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString] retain];
        
        [program link];
        
        [GPUContext setActiveShaderProgram:program];
        
        _positionSlot = [program attributeSlot:@"vPosition"];
        _textureSlot = [program attributeSlot:@"textureCoord"];
        _colorSlot = [program attributeSlot:@"color"];
        _samplerSlot = [program uniformIndex:@"inputImageTexture"];
        _samplerSlot2 = [program uniformIndex:@"sampler2"];
        _samplerSlot3 = [program uniformIndex:@"samplerMask"];
        
        _modelViewSlot = [program uniformIndex:@"modelViewMatrix"];
        _projectSlot = [program uniformIndex:@"projectMatrix"];
        
//        [self createFBO];
    }
    return self;
}

- (void)dealloc {
    [self destoryFBO];
    
    [super dealloc];
}

- (void)layoutSubviews {
//    [self destoryFBO];
//    [self createFBO];
//    [self draw];
}

#pragma mark - GPUInput

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [self draw];
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    if (!CGSizeEqualToSize(_size, newSize)) {
        _size = newSize;
    }
}

- (void)setInputFramebuffer:(GPUFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    _inputFramebuffer = newInputFramebuffer;
}

#pragma mark -

- (void)draw {
    [GPUContext setActiveShaderProgram:program];
    
    const GLfloat squarVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    const GLfloat textureCoordies[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };

//    static const GLfloat squarVertices[] = {
//        -1.0f, -1.0f,
//        1.0f, -1.0f,
//        -1.0f,  1.0f,
//        1.0f,  1.0f,
//    };
//    
//    static const GLfloat textureCoordies[] = {
//        0.0f, 0.0f,
//        1.0f, 0.0f,
//        0.0f, 1.0f,
//        1.0f, 1.0f,
//    };
    
    const GLubyte colors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };

    [self setDisplayFramebuffer];
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLfloat modelViewMatrix[16], projectMatrix[16];
    mat4f_LoadIdentity(projectMatrix);
    mat4f_LoadIdentity(modelViewMatrix);
    mat4f_LoadOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -5.0f, 5.0f, projectMatrix);

//    // scale
//    float s[3] = {
//        0.8, 0.8, 0.8,
//    };
//    mat4f_LoadScale(s, modelViewMatrix);
    // Rotation
//    mat4f_LoadRotation(modelViewMatrix, rotDegree, 0, 1, 0);
//    rotDegree += 1.0;
//    // Translation
//    rotDegree += 0.005;
//    float t[3] = {
//        rotDegree, 0, 0,
//    };
//    mat4f_LoadTranslation(t, modelViewMatrix);
//    
//    glUniformMatrix4fv(_modelViewSlot, 1, 0, modelViewMatrix);
//    glUniformMatrix4fv(_projectSlot, 1, 0, projectMatrix);
    
    glVertexAttribPointer(_positionSlot, 2, GL_FLOAT, GL_FALSE, 0, squarVertices);
    glEnableVertexAttribArray(_positionSlot);
    
    glVertexAttribPointer(_textureSlot, 2, GL_FLOAT, GL_FALSE, 0, textureCoordies);
    glEnableVertexAttribArray(_textureSlot);
    
    glVertexAttribPointer(_colorSlot, 4, GL_UNSIGNED_BYTE, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(_colorSlot);
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, [_inputFramebuffer texture]);
    glUniform1i(_samplerSlot, 6);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [[[GPUContext sharedImageProcessingContext] context] presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - FBO

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                     kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setDisplayFramebuffer {
    if (!_frameBuffer) {
        [self createFBO];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)createFBO {
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);

    [[[GPUContext sharedImageProcessingContext] context] renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
        
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

- (void)destoryFBO {
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
        _depthBuffer = 0;
    }
}

@end
