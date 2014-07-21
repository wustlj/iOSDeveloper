//
//  GPUInput.h
//  Movie
//
//  Created by lijian on 14-7-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@class GPUFramebuffer;

@protocol GPUInput <NSObject>

- (void)newFrameReadyAtTime:(CMTime)frameTime;
- (void)setInputFramebuffer:(GPUFramebuffer *)newInputFramebuffer;
- (void)setInputSize:(CGSize)newSize;

@end
