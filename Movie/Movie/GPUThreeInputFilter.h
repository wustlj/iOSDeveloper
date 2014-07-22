//
//  GPUThreeInputFilter.h
//  Movie
//
//  Created by lijian on 14-7-22.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUTwoInputFilter.h"

@interface GPUThreeInputFilter : GPUTwoInputFilter
{
    GLuint _threeTextureCoordinateAttribute;
    GLuint _threeSamplerSlot;
    GPUFramebuffer *_threeFramebuffer;
    BOOL _hadReceivedThreeFrame;
}
@end
