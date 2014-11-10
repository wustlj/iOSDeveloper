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

#import "GPUOutput.h"

@interface GPUImage : GPUOutput

- (id)initWithImage:(UIImage *)image;
- (id)initWithCGImage:(CGImageRef)imageRef;

- (void)processImage;

@end
