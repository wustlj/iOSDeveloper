//
//  GLESUtils.h
//  opengl_test_3
//
//  Created by Kalou on 13-6-8.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface GLESUtils : NSObject

+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;

+(GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath;

@end
