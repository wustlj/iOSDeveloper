//
//  GPULineFilter.h
//  Movie
//
//  Created by lijian on 14-7-22.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUFilter.h"

@interface GPULineFilter : GPUFilter
{
    GLuint _stepUniformSlot;
    int frameIndex;
}
@end