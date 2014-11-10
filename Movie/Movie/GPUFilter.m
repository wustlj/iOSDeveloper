//
//  GPUFilter.m
//  Movie
//
//  Created by lijian on 14-7-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUFilter.h"

NSString *const kFilterVertexShaderString = SHADER_STRING
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

NSString *const kFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordOut;
 
 uniform sampler2D sampler;
 
 void main()
 {
     gl_FragColor = texture2D(sampler, textureCoordOut);
 }
 );

@implementation GPUFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShader fragmentShaderFromString:(NSString *)fragmentShader {
    self = [super init];
    if (self) {
        _targets = [[NSMutableArray alloc] init];
        _currentFrameIndex = 0;
        
        runSynchronouslyOnVideoProcessingQueue(^{
            _filterProgram = [[[GPUContext sharedImageProcessingContext] programForVertexShaderString:vertexShader fragmentShaderString:fragmentShader] retain];
            
            [_filterProgram link];
            
            _positionAttribute = [_filterProgram attributeSlot:@"vPosition"];
            _textureCoordinateAttribute = [_filterProgram attributeSlot:@"textureCoord"];
            _samplerSlot = [_filterProgram uniformIndex:@"sampler"];
            
            [GPUContext setActiveShaderProgram:_filterProgram];
            
        });
    }
    return self;
}

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShader {
    if (!(self = [self initWithVertexShaderFromString:kFilterVertexShaderString fragmentShaderFromString:fragmentShader])) {
        return nil;
    }
    return self;
}

- (id)init {
    if (!(self = [self initWithFragmentShaderFromString:kFilterFragmentShaderString]))
    {
		return nil;
    }
    
    return self;
}

- (void)dealloc {
    [_filterProgram release];
    [_targets removeAllObjects];
    [_targets release];
    
    _firstFramebuffer = nil;
    
    [super dealloc];
}

- (CGSize)outputFrameSize {
    return _size;
}

#pragma mark - GPUInput

- (void)newAudioBuffer:(CMSampleBufferRef)bufferRef {
    [self informTargetsNewAudio:bufferRef];
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [self draw];
    
    _currentFrameIndex++;
    
    [self informTargetsNewFrame];
}

- (void)setInputFramebuffer:(id)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    _firstFramebuffer = newInputFramebuffer;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    _size = newSize;
}

- (NSInteger)nextAvailableTextureIndex {
    return 0;
}

#pragma mark - GPU

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
}

- (void)informTargetsNewFrame {
    for (id<GPUInput> target in _targets) {
        [target setInputSize:_size atIndex:0];
        [target setInputFramebuffer:_framebuffer atIndex:0];
        [target newFrameReadyAtTime:kCMTimeZero atIndex:0];
    }
}

- (void)addTarget:(id<GPUInput>)target {
    if (![_targets containsObject:target]) {
        [_targets addObject:target];
    }
}

- (void)informTargetsNewAudio:(CMSampleBufferRef)bufferRef {
    for (id<GPUInput> target in _targets) {
        [target newAudioBuffer:bufferRef];
    }
}

@end
