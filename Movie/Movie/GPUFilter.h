//
//  GPUFilter.h
//  Movie
//
//  Created by lijian on 14-7-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUInput.h"
#import "GPUFramebuffer.h"
#import "GPUContext.h"
#import "GPUProgram.h"

#import "GPUOutput.h"

extern NSString *const kFilterVertexShaderString;
extern NSString *const kFilterFragmentShaderString;

@interface GPUFilter : GPUOutput <GPUInput>
{
    GPUFramebuffer *_firstInputFramebuffer;
    GPUProgram *_filterProgram;
    GLuint _positionAttribute, _textureCoordinateAttribute;
    GLuint _samplerSlot;
    
    int _currentFrameIndex;
}

- (id)initWithVertexShaderFromString:(NSString *)vertexShader fragmentShaderFromString:(NSString *)fragmentShader;
- (id)initWithFragmentShaderFromString:(NSString *)fragmentShader;

@end
