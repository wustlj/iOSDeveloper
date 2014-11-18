//
//  GPUYuvToRgb.h
//  Movie
//
//  Created by lijian on 14/11/18.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUProgram.h"

@class GPUFramebuffer;

@interface GPUYuvToRgb : NSObject
{
    GPUProgram *_yuvConversionProgram;
    CVOpenGLESTextureCacheRef _textureCacheRef;
    
    GLuint _luminanceTexture, _chrominanceTexture;
    GLuint _yuvConversionPositionAttribute, _yuvConversionTextureCoordinateAttribute;
    GLint _yuvConversionLuminanceTextureUniform, _yuvConversionChrominanceTextureUniform;
    GLint _yuvConversionMatrixUniform;
}

- (void)processMovieFrame:(CVPixelBufferRef)movieFrame toFramebuffer:(GPUFramebuffer *)framebuffer;

@end
