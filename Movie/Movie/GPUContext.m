//
//  GPUContext.m
//  Movie
//
//  Created by lijian on 14-7-4.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUContext.h"

void runSynchronouslyOnVideoProcessingQueue(void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [GPUContext sharedContextQueue];
#if (!defined(__IPHONE_6_0) || (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0))
    if (dispatch_get_current_queue() == videoProcessingQueue)
#else
        if (dispatch_get_specific([GPUContext contextKey]))
#endif
        {
            block();
        }else
        {
            dispatch_sync(videoProcessingQueue, block);
        }
}

@implementation GPUContext

@synthesize context = _context;

static void *openGLESContextQueueKey;

- (id)init {
    self = [super init];
    if (self) {
         _contextQueue = dispatch_queue_create("com.sunsetlakesoftware.GPUImage.openGLESContextQueue", NULL);
    }
    return self;
}

+ (GPUContext *)sharedImageProcessingContext;
{
    static dispatch_once_t pred;
    static GPUContext *sharedImageProcessingContext = nil;
    
    dispatch_once(&pred, ^{
        sharedImageProcessingContext = [[[self class] alloc] init];
    });
    return sharedImageProcessingContext;
}

+ (void)useImageProcessingContext {
    EAGLContext *imageProcessingContext = [[GPUContext sharedImageProcessingContext] context];
    if ([EAGLContext currentContext] != imageProcessingContext) {
        [EAGLContext setCurrentContext:imageProcessingContext];
    }
}

+ (void)setActiveShaderProgram:(GPUProgram *)shaderProgram {
    GPUContext *sharedContext = [GPUContext sharedImageProcessingContext];
    EAGLContext *imageProcessingContext = [sharedContext context];
    if ([EAGLContext currentContext] != imageProcessingContext) {
        [EAGLContext setCurrentContext:imageProcessingContext];
    }
    
    if (sharedContext.currentShaderProgram != shaderProgram) {
        sharedContext.currentShaderProgram = shaderProgram;
        [shaderProgram use];
    }
}

+ (dispatch_queue_t)sharedContextQueue;
{
    return [[self sharedImageProcessingContext] contextQueue];
}

+ (void *)contextKey {
	return openGLESContextQueueKey;
}

- (EAGLContext *)context;
{
    if (_context == nil)
    {
        _context = [self createContext];
        [EAGLContext setCurrentContext:_context];
        
        // Set up a few global settings for the image processing pipeline
        glDisable(GL_DEPTH_TEST);
    }
    
    return _context;
}

- (EAGLContext *)createContext;
{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSAssert(context != nil, @"Unable to create an OpenGL ES 2.0 context. The GPUImage framework requires OpenGL ES 2.0 support to work.");
    return context;
}

- (GPUProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString {
    GPUProgram *program = [[GPUProgram alloc] initWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString];
    return [program autorelease];
}

- (CVOpenGLESTextureCacheRef)coreVideoTextureCache;
{
    if (_coreVideoTextureCache == NULL)
    {
#if defined(__IPHONE_6_0)
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [self context], NULL, &_coreVideoTextureCache);
#else
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge void *)[self context], NULL, &_coreVideoTextureCache);
#endif
        
        if (err)
        {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreate %d", err);
        }
        
    }
    
    return _coreVideoTextureCache;
}

@end
