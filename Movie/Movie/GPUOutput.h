//
//  GPUOutput.h
//  Movie
//
//  Created by lijian on 14/11/10.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUContext.h"
#import "GPUProgram.h"
#import "GPUInput.h"
#import "GPUFramebuffer.h"

@interface GPUOutput : NSObject
{
    GPUFramebuffer *_outputFramebuffer;
    CGSize _textureSize;
    
    NSMutableArray *_targets;
    NSMutableArray *_targetIndexs;
}

@property (readonly) GPUFramebuffer *outputFramebuffer;

- (void)addTarget:(id<GPUInput>)target;
- (void)removeTarget:(id<GPUInput>)target;
- (void)removeAllTargets;

- (void)notifyTargetsNewOutputTexture:(CMTime)time;
- (void)notifyTargetsNewOutputTexture:(CMTime)time withFramebuffer:(GPUFramebuffer *)framebuffer;

@end
