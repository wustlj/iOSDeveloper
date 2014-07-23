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

extern NSString *const kFilterVertexShaderString;
extern NSString *const kFilterFragmentShaderString;

@interface GPUFilter : NSObject <GPUInput>
{
    GPUFramebuffer *_framebuffer;
    GPUProgram *_filterProgram;
    GLuint _positionAttribute, _textureCoordinateAttribute;
    GLuint _samplerSlot;
    
    CGSize _size;
    int _currentFrameIndex;
    
    GPUFramebuffer *_firstFramebuffer;
    NSMutableArray *_targets;
}

- (id)initWithVertexShaderFromString:(NSString *)vertexShader fragmentShaderFromString:(NSString *)fragmentShader;
- (id)initWithFragmentShaderFromString:(NSString *)fragmentShader;

- (void)addTarget:(id<GPUInput>)target;
- (CGSize)outputFrameSize;

- (void)informTargetsNewFrame;

@end
