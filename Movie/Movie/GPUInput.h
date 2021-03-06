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

- (NSInteger)nextAvailableTextureIndex;
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
- (void)setInputFramebuffer:(GPUFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;

- (void)newAudioBuffer:(CMSampleBufferRef)bufferRef;

@optional
- (void)endProcessing;

@end
