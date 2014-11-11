//
//  GPUMovie.h
//  Movie
//
//  Created by lijian on 14-7-16.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>

#import "GPUProgram.h"
#import "GPUContext.h"

#import "GPUFramebuffer.h"
#import "GPUInput.h"

#import "GPUOutput.h"

@interface GPUMovie : GPUOutput
{
    GPUProgram *_yuvConversionProgram;
    GLuint _yuvConversionPositionAttribute, _yuvConversionTextureCoordinateAttribute;
    GLint _yuvConversionLuminanceTextureUniform, _yuvConversionChrominanceTextureUniform;
    GLint _yuvConversionMatrixUniform;
    GLuint _luminanceTexture;
    GLuint _chrominanceTexture;
    
    CVOpenGLESTextureCacheRef _textureCacheRef;
    
    AVAssetReader *_assetReader;
    AVAssetReaderTrackOutput *_videoTrackOutput;
    AVAssetReaderTrackOutput *_audioTrackOutput;
    
    int imageBufferWidth, imageBufferHeight;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) AVAsset *asset;

- (id)initWithURL:(NSURL *)url;

@property (nonatomic, assign) BOOL keepLooping;
- (void)startProcessing;
- (BOOL)readNextVideoFrame;

@property (nonatomic, copy) void (^completionBlock)(void);              // 视频所有桢处理完成
@property (nonatomic, copy) void (^currentFrameCompletionBlock)(void);  // 当前桢处理完成
@property (nonatomic, readonly) GLuint outputTexture;

- (void)appendFramebuffer:(GPUFramebuffer *)framebuffer;

@end
