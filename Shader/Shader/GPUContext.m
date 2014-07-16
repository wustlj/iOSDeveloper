//
//  GPUContext.m
//  Movie
//
//  Created by lijian on 14-7-4.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUContext.h"

@implementation GPUContext

@synthesize context = _context;

- (id)init {
    self = [super init];
    if (self) {
        
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

+ (void)setActiveShaderProgram:(GLProgram *)shaderProgram {
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

- (GLProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString {
    GLProgram *program = [[GLProgram alloc] initWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString];
    return [program autorelease];
}

@end
