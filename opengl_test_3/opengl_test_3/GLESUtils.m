//
//  GLESUtils.m
//  opengl_test_3
//
//  Created by Kalou on 13-6-8.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import "GLESUtils.h"

@implementation GLESUtils

+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString {
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        NSLog(@"create shader fail");
        return 0;
    }
    const char *shaderStringUTF8 = [shaderString UTF8String];
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    glCompileShader(shader);
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog (shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:\n%s\n", infoLog );
            
            free(infoLog);
        }
        
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

+(GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath {
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderFilepath encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        NSLog(@"Error: loading shader fail:%@", error.localizedDescription);
        return 0;
    }
    return [self loadShader:type withString:shaderString];
}

@end
