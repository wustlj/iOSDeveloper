//
//  GPUGridFilter.h
//  Movie
//
//  Created by lijian on 14-7-23.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUFilter.h"

@interface GPUGridFilter : GPUFilter
{
    GLfloat *_vertices;
    GLfloat *_texCoords;
}

@property (nonatomic, assign) NSInteger horizontalNum;
@property (nonatomic, assign) NSInteger verticalNum;
@property (nonatomic, assign) GLfloat intervalLength;

@end
