//
//  GPUImage.h
//  Movie
//
//  Created by lijian on 14-10-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUContext.h"
#import "GPUProgram.h"
#import "GPUInput.h"
#import "GPUFramebuffer.h"

@interface GPUImage : NSObject
{
    GPUFramebuffer *_outputFramebuffer;
    CGSize _size;
    NSMutableArray *_targets;
}

- (id)initWithImage:(UIImage *)image;
- (id)initWithCGImage:(CGImageRef)imageRef;

- (void)addTarget:(id<GPUInput>)target;

- (void)processImage;

@end
