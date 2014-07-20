//
//  GPUFramebuffer.m
//  Movie
//
//  Created by lijian on 14-7-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUFramebuffer.h"

#import "GPUContext.h"

@implementation GPUFramebuffer

@synthesize size = _size;
@synthesize texture = _outputTexture;

- (id)initWithSize:(CGSize)framebufferSize {
    self = [super init];
    if (self) {
        _size = framebufferSize;
        
        [self generateFramebuffer];
    }
    return self;
}

- (void)dealloc {
    [self destroyFramebuffer];
    
    [super dealloc];
}

- (void)generateFramebuffer {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUContext useImageProcessingContext];
        
        glGenFramebuffers(1, &_framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
        
        [self initializeOutputTexture];
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
        glBindTexture(GL_TEXTURE_2D, 0);
    });
}

- (void)destroyFramebuffer {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUContext useImageProcessingContext];
        
        if (_framebuffer) {
            glDeleteFramebuffers(1, &_framebuffer);
            _framebuffer = 0;
        }
        
        if (_renderTarget) {
            CFRelease(_renderTarget);
            _renderTarget = NULL;
        }
        
        if (_renderTexture) {
            CFRelease(_renderTexture);
            _renderTexture = NULL;
        }
        
        _outputTexture = 0;
    });
}

- (void)initializeOutputTexture {
    [GPUContext useImageProcessingContext];
    
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    
    CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, _size.width, _size.height, kCVPixelFormatType_32BGRA, attrs, &_renderTarget);
    if (err)
    {
        NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
    }
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, _textureCacheRef, _renderTarget,
                                                        NULL, // texture attributes
                                                        GL_TEXTURE_2D,
                                                        GL_RGBA, // opengl format
                                                        _size.width,
                                                        _size.height,
                                                        GL_BGRA, // native iOS format
                                                        GL_UNSIGNED_BYTE,
                                                        0,
                                                        &_renderTexture);
    if (err)
    {
        NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    CFRelease(attrs);
    CFRelease(empty);
    
    glBindTexture(CVOpenGLESTextureGetTarget(_renderTexture), CVOpenGLESTextureGetName(_renderTexture));
    _outputTexture = CVOpenGLESTextureGetName(_renderTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(_renderTexture), 0);
}

@end
