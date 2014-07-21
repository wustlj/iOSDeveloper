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

@interface GPUFilter : NSObject <GPUInput>
{
    GPUFramebuffer *_framebuffer;
    GPUProgram *_filterProgram;
    GLuint _positionAttribute, _textureCoordinateAttribute;
    GLuint _samplerSlot;
    
    CGSize _size;
    
    GPUFramebuffer *_firstFramebuffer;
    NSMutableArray *_targets;
}


- (void)addTarget:(id<GPUInput>)target;
- (CGSize)outputFrameSize;

@end
