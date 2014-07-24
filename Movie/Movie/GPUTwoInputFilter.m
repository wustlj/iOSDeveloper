//
//  GPUTwoInputFilter.m
//  Movie
//
//  Created by lijian on 14-7-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUTwoInputFilter.h"

NSString *const kGPUImageTwoInputTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 vPosition;
 attribute vec4 textureCoord;
 attribute vec4 textureCoord2;
 
 varying vec2 textureCoordOut;
 varying vec2 textureCoordOut2;
 
 void main()
 {
     gl_Position = vPosition;
     textureCoordOut = textureCoord.xy;
     textureCoordOut2 = textureCoord2.xy;
 }
 );

NSString *const kTwoFragmentShaderString = SHADER_STRING
(
 precision mediump float;

 varying vec2 textureCoordOut;
 varying vec2 textureCoordOut2;

 uniform sampler2D sampler;
 uniform sampler2D sampler2;

 void main()
 {
     vec4 base = texture2D(sampler, textureCoordOut);
     vec4 overlay = texture2D(sampler2, textureCoordOut2);

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

@implementation GPUTwoInputFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShader fragmentShaderFromString:(NSString *)fragmentShader {
    if (!(self = [super initWithVertexShaderFromString:vertexShader fragmentShaderFromString:fragmentShader])) {
        return nil;
    }
    _hadReceivedFirstFrame = NO;
    _hadReceivedSecondFrame = NO;
    _firstFramebuffer = nil;
    _secondFramebuffer = nil;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUContext useImageProcessingContext];
        
        _secondTextureCoordinateAttribute = [_filterProgram attributeSlot:@"textureCoord2"];
        _secondSamplerSlot = [_filterProgram uniformIndex:@"sampler2"];
    });
    
    return self;
}

- (id)init {
    if (!(self = [self initWithVertexShaderFromString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderFromString:kTwoFragmentShaderString])) {
        return nil;
    }
    return self;
}

- (void)dealloc {
    
    
    [super dealloc];
}

#pragma mark - GPUInput

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    if (_hadReceivedFirstFrame && _hadReceivedSecondFrame) {
        _hadReceivedFirstFrame = NO;
        _hadReceivedSecondFrame = NO;
        [self draw];
        
        [self informTargetsNewFrame];
    }
}

- (void)setInputFramebuffer:(GPUFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    if (0 == textureIndex) {
        _firstFramebuffer = newInputFramebuffer;
        _hadReceivedFirstFrame = YES;
    } else {
        _secondFramebuffer = newInputFramebuffer;
        _hadReceivedSecondFrame = YES;
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    _size = newSize;
}

#pragma mark - 

- (void)draw {
    static const GLfloat squarVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureCoordies[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    [GPUContext setActiveShaderProgram:_filterProgram];
    
    if (!_framebuffer) {
        _framebuffer = [[GPUFramebuffer alloc] initWithSize:_size];
    }
    
    [_framebuffer activateFramebuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [_firstFramebuffer texture]);
    glUniform1i(_samplerSlot, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_secondFramebuffer texture]);
    glUniform1i(_secondSamplerSlot, 3);
    
    glEnableVertexAttribArray(_positionAttribute);
    glEnableVertexAttribArray(_textureCoordinateAttribute);
    glEnableVertexAttribArray(_secondTextureCoordinateAttribute);
    
    glVertexAttribPointer(_positionAttribute, 2, GL_FLOAT, 0, 0, squarVertices);
    glVertexAttribPointer(_textureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordies);
    glVertexAttribPointer(_secondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordies);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
