//
//  GPUTransformFilter.h
//  Movie
//
//  Created by lijian on 14-7-24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUFilter.h"

@interface GPUTransformFilter : GPUFilter
{
    GLuint _modelViewMatrixSlot;
    GLuint _projectMatrixSlot;
    
    float *modelViewMatrix;
    float *projectMatrix;
}

@property (nonatomic, assign) CATransform3D transform3D;

@end
