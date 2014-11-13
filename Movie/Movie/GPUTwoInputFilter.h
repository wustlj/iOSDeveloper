//
//  GPUTwoInputFilter.h
//  Movie
//
//  Created by lijian on 14-7-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUFilter.h"

@interface GPUTwoInputFilter : GPUFilter
{
    GLuint _secondTextureCoordinateAttribute;
    GLuint _secondSamplerSlot;
    GPUFramebuffer *_secondInputFramebuffer;
    BOOL _hadReceivedFirstFrame, _hadReceivedSecondFrame;
    BOOL _hadSetFirstTexture;
}
@end
