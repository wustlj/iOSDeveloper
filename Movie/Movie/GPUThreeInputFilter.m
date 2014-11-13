//
//  GPUThreeInputFilter.m
//  Movie
//
//  Created by lijian on 14-7-22.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUThreeInputFilter.h"

NSString *const kGPUImageThreeInputTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 vPosition;
 attribute vec4 textureCoord;
 attribute vec4 textureCoord2;
 attribute vec4 textureCoord3;
 
 varying vec2 textureCoordOut;
 varying vec2 textureCoordOut2;
 varying vec2 textureCoordOut3;
 
 void main()
 {
     gl_Position = vPosition;
     textureCoordOut = textureCoord.xy;
     textureCoordOut2 = textureCoord2.xy;
     textureCoordOut3 = textureCoord3.xy;
 }
 );

NSString *const kThreeFragmentShaderString = SHADER_STRING
(
 precision mediump float;

 varying vec2 textureCoordOut;
 varying vec2 textureCoordOut2;
 varying vec2 textureCoordOut3;

 uniform sampler2D sampler;
 uniform sampler2D sampler2;
 uniform sampler2D sampler3;
 
 const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

 void main()
 {
     vec4 base = texture2D(sampler, textureCoordOut);
     vec4 overlay = texture2D(sampler2, textureCoordOut2);
     vec4 mask = texture2D(sampler3, textureCoordOut3);
     
     float lum = dot(mask.rgb, luminanceWeighting);
     gl_FragColor = mix(base, overlay, lum);
 }
);


@implementation GPUThreeInputFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShader fragmentShaderFromString:(NSString *)fragmentShader {
    if (!(self = [super initWithVertexShaderFromString:vertexShader fragmentShaderFromString:fragmentShader])) {
        return nil;
    }
    
    _hadSetSecondTexture = NO;
    _hadReceivedThreeFrame = NO;
    _threeInputFramebuffer = nil;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUContext useImageProcessingContext];
        
        _threeTextureCoordinateAttribute = [_filterProgram attributeSlot:@"textureCoord3"];
        _threeSamplerSlot = [_filterProgram uniformIndex:@"sampler3"];
    });
    
    return self;
}

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShader {
    if (!(self = [self initWithVertexShaderFromString:kGPUImageThreeInputTextureVertexShaderString fragmentShaderFromString:fragmentShader])) {
        return nil;
    }
    return self;
}

- (id)init {
    if (!(self = [self initWithFragmentShaderFromString:kThreeFragmentShaderString])) {
        return nil;
    }
    return self;
}

- (void)dealloc {
    _threeInputFramebuffer = nil;
    
    [super dealloc];
}

#pragma mark - GPUInput

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    if (_hadReceivedFirstFrame && _hadReceivedSecondFrame && _hadReceivedThreeFrame) {
        return;
    }
    
    if (0 == textureIndex) {
        _hadReceivedFirstFrame = YES;
    } else if (1 == textureIndex) {
        _hadReceivedSecondFrame = YES;
    } else {
        _hadReceivedThreeFrame = YES;
    }
    
    if (_hadReceivedFirstFrame && _hadReceivedSecondFrame && _hadReceivedThreeFrame) {
        _hadReceivedThreeFrame = NO;
        _hadReceivedFirstFrame = NO;
        _hadReceivedSecondFrame = NO;
        [self draw];
        
        [self notifyTargetsNewOutputTexture:frameTime];
    }
}

- (void)setInputFramebuffer:(GPUFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    if (0 == textureIndex) {
        _firstInputFramebuffer = newInputFramebuffer;
        _hadSetFirstTexture = YES;
    } else if (1 == textureIndex) {
        _secondInputFramebuffer = newInputFramebuffer;
        _hadSetSecondTexture = YES;
    } else {
        _threeInputFramebuffer = newInputFramebuffer;
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    _textureSize = newSize;
}

- (NSInteger)nextAvailableTextureIndex {
    if (_hadSetSecondTexture) {
        return 2;
    } else if (_hadSetFirstTexture) {
        return 1;
    } else {
        return 0;
    }
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
    
    if (!_outputFramebuffer) {
        _outputFramebuffer = [[GPUFramebuffer alloc] initWithSize:_textureSize];
    }
    
    [_outputFramebuffer activateFramebuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [_firstInputFramebuffer texture]);
    glUniform1i(_samplerSlot, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_secondInputFramebuffer texture]);
    glUniform1i(_secondSamplerSlot, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [_threeInputFramebuffer texture]);
    glUniform1i(_threeSamplerSlot, 4);
    
    glEnableVertexAttribArray(_positionAttribute);
    glEnableVertexAttribArray(_textureCoordinateAttribute);
    glEnableVertexAttribArray(_secondTextureCoordinateAttribute);
    glEnableVertexAttribArray(_threeTextureCoordinateAttribute);
    
    glVertexAttribPointer(_positionAttribute, 2, GL_FLOAT, 0, 0, squarVertices);
    glVertexAttribPointer(_textureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordies);
    glVertexAttribPointer(_secondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordies);
    glVertexAttribPointer(_threeTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordies);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
