//
//  GPUContext.h
//  Movie
//
//  Created by lijian on 14-7-4.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "GPUProgram.h"

struct GPURect {
    GLfloat left;
    GLfloat right;
    GLfloat bottom;
    GLfloat top;
};
typedef struct GPURect GPURect;

GPURect
GPURectMake(GLfloat left, GLfloat right, GLfloat bottom, GLfloat top);

void runSynchronouslyOnVideoProcessingQueue(void (^block)(void));

@interface GPUContext : NSObject
{
    CVOpenGLESTextureCacheRef _coreVideoTextureCache;
}

@property(readonly, retain, nonatomic) EAGLContext *context;
@property(readwrite, retain, nonatomic) GPUProgram *currentShaderProgram;
@property(readonly, nonatomic) dispatch_queue_t contextQueue;

+ (GPUContext *)sharedImageProcessingContext;
+ (dispatch_queue_t)sharedContextQueue;
+ (void *)contextKey;

+ (void)useImageProcessingContext;
+ (void)setActiveShaderProgram:(GPUProgram *)shaderProgram;

- (GPUProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString;
- (CVOpenGLESTextureCacheRef)coreVideoTextureCache;

@end
