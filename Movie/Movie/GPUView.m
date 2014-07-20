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
    gl_Position = projectMatrix * modelViewMatrix * vPosition;
    colorVarying = color;
    textureCoordOut = textureCoord;
 }
);



NSString *const kThreeFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 
 varying vec4 colorVarying;
 varying vec2 textureCoordOut;
 
 uniform sampler2D sampler;
 uniform sampler2D sampler2;
 uniform sampler2D samplerMask;
 
 void main()
 {
     vec4 base = texture2D(sampler, textureCoordOut);
     vec4 overlay = texture2D(sampler2, textureCoordOut);
     vec4 mask = texture2D(samplerMask, textureCoordOut);
     
     mediump float lum = mask.r * 0.299 + mask.g * 0.587 + mask.b * 0.114;
     
     gl_FragColor = mix(base, overlay, lum);
 }
);

NSString *const kTwoFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 
 varying vec4 colorVarying;
 varying vec2 textureCoordOut;
 
 uniform sampler2D sampler;
 uniform sampler2D sampler2;
 uniform sampler2D samplerMask;
 
 void main()
 {
     vec4 base = texture2D(sampler, textureCoordOut);
     vec4 overlay = texture2D(sampler2, textureCoordOut);
     
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
        
        program = [[[GPUContext sharedImageProcessingContext] programForVertexShaderString:kVertexShaderString fragmentShaderString:kThreeFragmentShaderString] retain];
        
        [program link];
        
        [GPUContext setActiveShaderProgram:program];
        
        _positionSlot = [program attributeSlot:@"vPosition"];
        _textureSlot = [program attributeSlot:@"textureCoord"];
        _colorSlot = [program attributeSlot:@"color"];
        _samplerSlot = [program uniformIndex:@"sampler"];
        _samplerSlot2 = [program uniformIndex:@"sampler2"];
        _samplerSlot3 = [program uniformIndex:@"samplerMask"];
        
        _modelViewSlot = [program uniformIndex:@"modelViewMatrix"];
        _projectSlot = [program uniformIndex:@"projectMatrix"];
        
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
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    const GLubyte colors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
//    glEnable(GL_CULL_FACE);
    
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
    mat4f_LoadRotation(modelViewMatrix, rotDegree, 0, 1, 0);
    rotDegree += 1.0;
//    // Translation
//    rotDegree += 0.005;
//    float t[3] = {
//        rotDegree, 0, 0,
//    };
//    mat4f_LoadTranslation(t, modelViewMatrix);
    
    glUniformMatrix4fv(_modelViewSlot, 1, 0, modelViewMatrix);
    glUniformMatrix4fv(_projectSlot, 1, 0, projectMatrix);
    
    glVertexAttribPointer(_positionSlot, 2, GL_FLOAT, GL_FALSE, 0, vertex);
    glEnableVertexAttribArray(_positionSlot);
    
    glVertexAttribPointer(_textureSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoord);
    glEnableVertexAttribArray(_textureSlot);
    
    glVertexAttribPointer(_colorSlot, 4, GL_UNSIGNED_BYTE, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(_colorSlot);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _outputTexture);
    glUniform1i(_samplerSlot, 1);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, _outputTexture2);
    glUniform1i(_samplerSlot2, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, _maskTexture);
    glUniform1i(_samplerSlot3, 3);
    
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
