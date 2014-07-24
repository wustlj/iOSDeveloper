//
//  GPUPartFilter.m
//  Movie
//
//  Created by lijian on 14-7-22.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUPartFilter.h"

#define FRAME_NUM_PER_PART 30

@implementation GPUPartFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShader fragmentShaderFromString:(NSString *)fragmentShader {
    if (!(self = [super initWithVertexShaderFromString:vertexShader fragmentShaderFromString:fragmentShader])) {
        return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
    });
    
    return self;
}

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShader {
    if (!(self = [self initWithVertexShaderFromString:kFilterVertexShaderString fragmentShaderFromString:fragmentShader])) {
        return nil;
    }
    return self;
}

- (id)init {
    if (!(self = [self initWithFragmentShaderFromString:kFilterFragmentShaderString])) {
        return nil;
    }
    return self;
}

#pragma mark - Draw

- (void)draw {
    if (_currentFrameIndex <= FRAME_NUM_PER_PART * 1) {
        [self drawPart:1];
    } else if (_currentFrameIndex <= FRAME_NUM_PER_PART * 2) {
        [self drawPart:1];
        [self drawPart:2];
    } else if ((_currentFrameIndex <= FRAME_NUM_PER_PART * 3)) {
        [self drawPart:1];
        [self drawPart:2];
        [self drawPart:3];
    } else if ((_currentFrameIndex <= FRAME_NUM_PER_PART * 4)) {
        [self drawPart:1];
        [self drawPart:2];
        [self drawPart:3];
        [self drawPart:4];
    } else {
        [self drawAll];
    }
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
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
    
    glEnableVertexAttribArray(_positionAttribute);
    glEnableVertexAttribArray(_textureCoordinateAttribute);
    
    glVertexAttribPointer(_positionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(_textureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark - Part

- (void)drawAll {
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
}

- (void)drawPart:(int)part {
    GLfloat squarVertices[8];
    GLfloat textureCoordies[8];
    
    float blackWidth = 0.02;
    
    float xFactor = 0.3;
    float yFactor = 0.5;
    
    float x , y;
    if (part == 1) {
        x = 1 - xFactor;
        y = 1 - yFactor;
        
        squarVertices[0] = - 1.0f;
        squarVertices[1] = 1.0f - 2.0f * y;
        squarVertices[2] = -1.0f + 2.0f * x;
        squarVertices[3] = 1.0f - 2.0f * y;
        squarVertices[4] = -1.0f;
        squarVertices[5] = 1.0f;
        squarVertices[6] = -1.0f + 2.0f * x;
        squarVertices[7] = 1.0f;
        
        textureCoordies[0] = 0.0f;
        textureCoordies[1] = 1.0 - y;
        textureCoordies[2] = x;
        textureCoordies[3] = 1.0 - y;
        textureCoordies[4] = 0.0f;
        textureCoordies[5] = 1.0f;
        textureCoordies[6] = x;
        textureCoordies[7] = 1.0f;
    } else if (part == 2) {
        x = xFactor;
        y = 1- yFactor;
        squarVertices[0] = 1.0f - 2.0f * x + blackWidth;
        squarVertices[1] = 1.0f - 2.0f * y;
        squarVertices[2] = 1.0f;
        squarVertices[3] = 1.0f - 2.0f * y;
        squarVertices[4] = 1.0f - 2.0f * x + blackWidth;
        squarVertices[5] = 1.0f;
        squarVertices[6] = 1.0f;
        squarVertices[7] = 1.0f;
        
        textureCoordies[0] = 1.0f - x;
        textureCoordies[1] = 1.0f - y;
        textureCoordies[2] = 1.0f;
        textureCoordies[3] = 1.0f - y;
        textureCoordies[4] = 1.0f - x;
        textureCoordies[5] = 1.0f;
        textureCoordies[6] = 1.0f;
        textureCoordies[7] = 1.0f;
    } else if (part == 3) {
        x = xFactor;
        y = yFactor;
        
        squarVertices[0] = -1.0f;
        squarVertices[1] = -1.0f;
        squarVertices[2] = -1.0f + 2.0f * x;
        squarVertices[3] = -1.0f;
        squarVertices[4] = -1.0f;
        squarVertices[5] = -1.0f + 2.0f * y - blackWidth;
        squarVertices[6] = -1.0f + 2.0f * x;
        squarVertices[7] = -1.0f + 2.0f * y - blackWidth;
        
        textureCoordies[0] = 0.0f;
        textureCoordies[1] = 0.0f;
        textureCoordies[2] = x;
        textureCoordies[3] = 0.0f;
        textureCoordies[4] = 0.0f;
        textureCoordies[5] = y;
        textureCoordies[6] = x;
        textureCoordies[7] = y;
    } else if (part == 4) {
        x = 1- xFactor;
        y = yFactor;
        
        squarVertices[0] = 1.0f - (2.0f * x - blackWidth);
        squarVertices[1] = -1.0f;
        squarVertices[2] = 1.0f;
        squarVertices[3] = -1.0f;
        squarVertices[4] = 1.0f - (2.0f * x - blackWidth);
        squarVertices[5] = -1.0f + 2.0f * y - blackWidth;
        squarVertices[6] = 1.0f;
        squarVertices[7] = -1.0f + 2.0f * y - blackWidth;
        
        textureCoordies[0] = 1.0f - x;
        textureCoordies[1] = 0.0f;
        textureCoordies[2] = 1.0f;
        textureCoordies[3] = 0.0f;
        textureCoordies[4] = 1.0f - x;
        textureCoordies[5] = y;
        textureCoordies[6] = 1.0f;
        textureCoordies[7] = y;
    }
    
    [self renderToTextureWithVertices:squarVertices textureCoordinates:textureCoordies];
}

@end
