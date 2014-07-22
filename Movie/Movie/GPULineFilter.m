//
//  GPULineFilter.m
//  Movie
//
//  Created by lijian on 14-7-22.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPULineFilter.h"

#define LINE_SCROLL_COUNT 60

NSString *const kLineFilterVertexShaderString = SHADER_STRING
(
 attribute vec4 vPosition;
 attribute vec2 textureCoord;
 
 varying vec2 textureCoordOut;
 
 void main()
 {
     gl_Position = vPosition;
     textureCoordOut = textureCoord;
 }
 );

NSString *const kLineFilterFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 
 varying vec2 textureCoordOut;
 
 uniform sampler2D sampler;
 uniform int lineStep;
 
 void main()
 {
     if (lineStep == 0) {
         gl_FragColor = texture2D(sampler, textureCoordOut);
     } else {
         gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
     }
 }
 );

@implementation GPULineFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShader fragmentShaderFromString:(NSString *)fragmentShader {
    if (!(self = [super initWithVertexShaderFromString:vertexShader fragmentShaderFromString:fragmentShader])) {
        return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        _stepUniformSlot = [_filterProgram uniformIndex:@"lineStep"];
    });
    
    return self;
}

- (id)init {
    if (!(self = [self initWithVertexShaderFromString:kLineFilterVertexShaderString fragmentShaderFromString:kLineFilterFragmentShaderString])) {
        return nil;
    }
    return self;
}

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
    
    [self renderToTextureWithVertices:squarVertices textureCoordinates:textureCoordies];
    
    [self renderHorizontalLineWithRect:GPURectMake(-0.6, 0.6, 0.4, 0.42)];
    [self renderVerticalLineWithRect:GPURectMake(-0.58, -0.6, 0.0, 1.0)];
    frameIndex++;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    [GPUContext setActiveShaderProgram:_filterProgram];
    
    if (!_framebuffer) {
        _framebuffer = [[GPUFramebuffer alloc] initWithSize:_size];
    }
    
    [_framebuffer activateFramebuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BITS);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [_firstFramebuffer texture]);
    glUniform1i(_samplerSlot, 2);
    
    glUniform1i(_stepUniformSlot, 0);
    
    glEnableVertexAttribArray(_positionAttribute);
    glEnableVertexAttribArray(_textureCoordinateAttribute);
    
    glVertexAttribPointer(_positionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(_textureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)renderHorizontalLineWithRect:(GPURect)rect {
    if (frameIndex >= LINE_SCROLL_COUNT) {
        return;
    }
    
    GLfloat lineVertices[8];
    GLfloat movePerFrame = 1.6f / LINE_SCROLL_COUNT;
    lineVertices[0] = rect.left + movePerFrame * frameIndex;
    lineVertices[1] = rect.bottom;
    lineVertices[2] = rect.right + movePerFrame * frameIndex;
    lineVertices[3] = rect.bottom;
    lineVertices[4] = rect.left + movePerFrame * frameIndex;
    lineVertices[5] = rect.top;
    lineVertices[6] = rect.right + movePerFrame * frameIndex;
    lineVertices[7] = rect.top;
    
    glUniform1i(_stepUniformSlot, 1);
    
    glVertexAttribPointer(_positionAttribute, 2, GL_FLOAT, 0, 0, lineVertices);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)renderVerticalLineWithRect:(GPURect)rect {
    if (frameIndex >= LINE_SCROLL_COUNT) {
        return;
    }
    
    GLfloat lineVertices[8];
    GLfloat movePerFrame = 2.0f / LINE_SCROLL_COUNT;
    lineVertices[0] = rect.left;
    lineVertices[1] = rect.bottom - movePerFrame * frameIndex;
    lineVertices[2] = rect.right;
    lineVertices[3] = rect.bottom - movePerFrame * frameIndex;
    lineVertices[4] = rect.left;
    lineVertices[5] = rect.top - movePerFrame * frameIndex;
    lineVertices[6] = rect.right;
    lineVertices[7] = rect.top - movePerFrame * frameIndex;
    
    glUniform1i(_stepUniformSlot, 1);
    
    glVertexAttribPointer(_positionAttribute, 2, GL_FLOAT, 0, 0, lineVertices);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
