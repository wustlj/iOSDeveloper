//
//  GPUInput.h
//  Movie
//
//  Created by lijian on 14-7-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPUFramebuffer;

@protocol GPUInput <NSObject>

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer;
- (void)setInputSize:(CGSize)newSize;

@end
