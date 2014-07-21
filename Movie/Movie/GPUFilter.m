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

NSString *const kFilterTwoFragmentShaderString = SHADER_STRING
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
//     vec4 overlay = texture2D(sampler2, textureCoordOut);
//     
//     mediump float r;
//     if (overlay.r * base.a + base.r * overlay.a >= overlay.a * base.a) {
//         r = overlay.a * base.a + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
//     } else {
//         r = overlay.r + base.r;
//     }
//     
//     mediump float g;
//     if (overlay.g * base.a + base.g * overlay.a >= overlay.a * base.a) {
//         g = overlay.a * base.a + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
//     } else {
//         g = overlay.g + base.g;
//     }
//     
//     mediump float b;
//     if (overlay.b * base.a + base.b * overlay.a >= overlay.a * base.a) {
//         b = overlay.a * base.a + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
//     } else {
//         b = overlay.b + base.b;
//     }
//     
//     mediump float a = overlay.a + base.a - overlay.a * base.a;
//     gl_FragColor = vec4(r,g,b,a);

     base.r = 1.0;
     gl_FragColor = base;
 }
 );

@implementation GPUFilter

- (id)init {
    self = [super init];
    if (self) {
        _targets = [[NSMutableArray alloc] init];
        
        runSynchronouslyOnVideoProcessingQueue(^{
            _filterProgram = [[[GPUContext sharedImageProcessingContext] programForVertexShaderString:kFilterVertexShaderString fragmentShaderString:kFilterTwoFragmentShaderString] retain];
            
            [_filterProgram link];
            
            _positionAttribute = [_filterProgram attributeSlot:@"vPosition"];
            _textureCoordinateAttribute = [_filterProgram attributeSlot:@"textureCoord"];
            _samplerSlot = [_filterProgram uniformIndex:@"sampler"];
            
            [GPUContext setActiveShaderProgram:_filterProgram];
        });
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

- (void)addTarget:(id<GPUInput>)target {
    if (![_targets containsObject:target]) {
        [_targets addObject:target];
    }
}

- (CGSize)outputFrameSize {
    return _size;
}

#pragma mark - GPUInput

- (void)newFrameReadyAtTime:(CMTime)frameTime {
    [self draw];
    
    [self informTargetsNewFrame];
}

- (void)setInputFramebuffer:(id)newInputFramebuffer {
    _firstFramebuffer = newInputFramebuffer;
}

- (void)setInputSize:(CGSize)newSize {
    _size = newSize;
}

#pragma mark - GPU

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
        [target setInputSize:_size];
        [target setInputFramebuffer:_framebuffer];
        [target newFrameReadyAtTime:kCMTimeZero];
    }
}

@end
