//
//  GPUGridFilter.m
//  Movie
//
//  Created by lijian on 14-7-23.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUGridFilter.h"

#define SPACE 0.2

@implementation GPUGridFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShader fragmentShaderFromString:(NSString *)fragmentShader {
    if (!(self = [super initWithVertexShaderFromString:vertexShader fragmentShaderFromString:fragmentShader])) {
        return nil;
    }
    
    _verticalNum = 4;
    _horizontalNum = 4;
    
    _intervalLength = 0.02;
    
    [self initVerticesAndTexutreCoords];

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

- (void)initVerticesAndTexutreCoords {
    float count = _verticalNum * _horizontalNum * 4 * 2;
    _vertices = calloc(count, sizeof(GLfloat));
    _texCoords = calloc(count, sizeof(GLfloat));
    
    float space = _intervalLength;
    float width = (2.0 - (_horizontalNum - 1) * space) / _horizontalNum;
    float height = (2.0 - (_verticalNum - 1) * space) / _verticalNum;
    float cWidth = 1.0 / _horizontalNum;
    float cHeight = 1.0 / _verticalNum;
    float x, y;
    
    for (int row = 0; row < _horizontalNum; row ++) {
        for (int column = 0; column < _verticalNum; column ++) {
            x = y = -1.0f;
            int index = row * _horizontalNum * 4 * 2 + column * 4 * 2;
            _vertices[index + 0] = x + (width + space) * row;
            _vertices[index + 1] = y + (height + space) * column;
            _vertices[index + 2] = _vertices[index + 0] + width;
            _vertices[index + 3] = _vertices[index + 1];
            _vertices[index + 4] = _vertices[index + 0];
            _vertices[index + 5] = _vertices[index + 1] + height;
            _vertices[index + 6] = _vertices[index + 0] + width;
            _vertices[index + 7] = _vertices[index + 1] + height;
            
            x = y = 0.0f;
            _texCoords[index + 0] = x + cWidth * row;
            _texCoords[index + 1] = y + cHeight * column;
            _texCoords[index + 2] = _texCoords[index + 0] + cWidth;
            _texCoords[index + 3] = _texCoords[index + 1];
            _texCoords[index + 4] = _texCoords[index + 0];
            _texCoords[index + 5] = _texCoords[index + 1] + cHeight;
            _texCoords[index + 6] = _texCoords[index + 0] + cWidth;
            _texCoords[index + 7] = _texCoords[index + 1] + cHeight;
            
        }
    }
}

#pragma mark -

- (void)setHorizontalNum:(NSInteger)horizontalNum {
    if (horizontalNum) {
        _horizontalNum = horizontalNum;
    }
}

- (void)setVerticalNum:(NSInteger)verticalNum {
    if (verticalNum) {
        _verticalNum = verticalNum;
    }
}

- (void)setIntervalLength:(float)intervalLength {
    if (intervalLength && intervalLength < 1.0) {
        _intervalLength = intervalLength;
    }
}

#pragma mark - 

- (void)draw {
    for (int i = 0; i < _horizontalNum; i++) {
        for (int j = 0; j < _verticalNum; j++) {
            int index = i * _horizontalNum * 4 * 2 + j * 4 * 2;
            [self renderToTextureWithVertices:(_vertices + index)  textureCoordinates:(_texCoords + index)];
        }
    }
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
    
    glEnableVertexAttribArray(_positionAttribute);
    glEnableVertexAttribArray(_textureCoordinateAttribute);
    
    glVertexAttribPointer(_positionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(_textureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
