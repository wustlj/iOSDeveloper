//
//  GPUImage.m
//  Movie
//
//  Created by lijian on 14-10-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUImage.h"

@implementation GPUImage

- (id)initWithImage:(UIImage *)image
{
    return [self initWithCGImage:image.CGImage];
}

- (id)initWithCGImage:(CGImageRef)imageRef
{
    self = [super init];
    if (self) {
        _targets = [[NSMutableArray alloc] init];
        
        GLfloat widthOfImage = CGImageGetWidth(imageRef);
        GLfloat heightOfImage = CGImageGetHeight(imageRef);
        _size = CGSizeMake(widthOfImage, heightOfImage);

        GLubyte *imageData = NULL;
        CFDataRef dataFromImageDataProvider = NULL;
        
        dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
        imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
        
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUContext useImageProcessingContext];
            _outputFramebuffer = [[GPUFramebuffer alloc] initOnlyTextureWithSize:_size];
            glBindTexture(GL_TEXTURE_2D, _outputFramebuffer.texture);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage, (int)heightOfImage, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
            glBindTexture(GL_TEXTURE_2D, 0);
        });
        
        CFRelease(dataFromImageDataProvider);
    }
    return self;
}

- (void)dealloc
{
    [_outputFramebuffer release];
    [_targets release];
    
    [super dealloc];
}

- (void)addTarget:(id<GPUInput>)target
{
    if (![_targets containsObject:target]) {
        [_targets addObject:target];
    }
}

- (void)processImage
{
    runSynchronouslyOnVideoProcessingQueue(^{
        for (id<GPUInput>target in _targets) {
            [target setInputFramebuffer:_outputFramebuffer atIndex:0];
            [target setInputSize:_size atIndex:0];
            [target newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
            [target newAudioBuffer:NULL];
        }
    });
}

@end
