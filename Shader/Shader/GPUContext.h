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

#import "GLProgram.h"

@interface GPUContext : NSObject

@property(readonly, retain, nonatomic) EAGLContext *context;
@property(readwrite, retain, nonatomic) GLProgram *currentShaderProgram;

+ (GPUContext *)sharedImageProcessingContext;

+ (void)useImageProcessingContext;
+ (void)setActiveShaderProgram:(GLProgram *)shaderProgram;

- (GLProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString;

@end
