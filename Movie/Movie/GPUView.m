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
 attribute vec2 textureCoord2;
 
 uniform mat4 modelViewMat;
 uniform mat4 projectMat;
 
 varying vec4 colorVarying;
 varying vec2 textureCoordOut;
 varying vec2 textureCoordOut2;
 
 void main()
 {
    gl_Position = vPosition;
    colorVarying = color;
    textureCoordOut = textureCoord;
 }
);



NSString *const kFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 
 varying vec4 colorVarying;
 varying vec2 textureCoordOut;
 varying vec2 textureCoordOut2;
 
 uniform sampler2D sampler;
 uniform sampler2D sampler2;
 
 void main()
 {
     vec4 base = texture2D(sampler, textureCoordOut);
     base.a = 1.0;
     vec4 overlay = texture2D(sampler2, textureCoordOut);
     overlay.a = 1.0;
     
     mediump float r;
     if (overlay.r * base.a + base.r * overlay.a >= overlay.a * base.a) {
         r = overlay.a * base.a + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
     } else {
         r = overlay.r + base.r;
     }
     
     mediump float g;
     if (overlay.g * base.a + base.g * overlay.a >= overlay.a * base.a) {
         g = overlay.a * base.a + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
     } else {
         g = overlay.g + base.g;
     }
     
     mediump float b;
     if (overlay.b * base.a + base.b * overlay.a >= overlay.a * base.a) {
         b = overlay.a * base.a + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
     } else {
         b = overlay.b + base.b;
     }
     
     mediump float a = overlay.a + base.a - overlay.a * base.a;
     
     gl_FragColor = vec4(r,g,b,a);

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
        
        program = [[[GPUContext sharedImageProcessingContext] programForVertexShaderString:kVertexShaderString fragmentShaderString:kFragmentShaderString] retain];
        
        [program link];
        
        [GPUContext setActiveShaderProgram:program];
        
        _positionSlot = [program attributeSlot:@"vPosition"];
        _textureSlot = [program attributeSlot:@"textureCoord"];
        _colorSlot = [program attributeSlot:@"color"];
        _modelViewSlot = [program uniformIndex:@"modelViewMat"];
        _projectSlot = [program uniformIndex:@"projectMat"];
        _samplerSlot = [program uniformIndex:@"sampler"];
        _colorSlot2 = [program attributeSlot:@"textureCoord2"];
        _samplerSlot2 = [program uniformIndex:@"sampler2"];
        
        [self createFBO];
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

- (void)draw {
    [GPUContext setActiveShaderProgram:program];
    
    const GLfloat vertex[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    const GLfloat texCoord[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    const GLubyte colors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
//    GLfloat modelViewMat[16], projectMat[16];
//    
//    mat4f_LoadIdentity(projectMat);
//    mat4f_LoadIdentity(modelViewMat);
//
//    mat4f_LoadOrtho(-1.0f, 1.0f, -1.5f, 1.5f, -5.0f, 5.0f, projectMat);
//    mat4f_LoadRotation(modelViewMat, 0, 1, 0, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glEnable(GL_CULL_FACE);
    
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glVertexAttribPointer(_positionSlot, 2, GL_FLOAT, GL_FALSE, 0, vertex);
    glEnableVertexAttribArray(_positionSlot);
    
    glVertexAttribPointer(_textureSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoord);
    glEnableVertexAttribArray(_textureSlot);
    
    glVertexAttribPointer(_colorSlot, 4, GL_UNSIGNED_BYTE, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(_colorSlot);
    
//    glUniformMatrix4fv(_modelViewSlot, 1, 0, modelViewMat);
//    glUniformMatrix4fv(_projectSlot, 1, 0, projectMat);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _outputTexture);
    glUniform1i(_samplerSlot, 1);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, _outputTexture2);
    glUniform1i(_samplerSlot2, 2);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
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
//    [self initializeOutputTexture];
    
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
    
    if (_outputTexture) {
        glDeleteTextures(1, &_outputTexture);
        _outputTexture = 0;
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
