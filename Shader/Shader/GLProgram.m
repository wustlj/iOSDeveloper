//
//  GLProgram.m
//  Movie
//
//  Created by lijian on 14-7-4.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GLProgram.h"

@implementation GLProgram

- (id)initWithVertexShaderString:(NSString *)vShaderString fragmentShaderString:(NSString *)fShaderString {
    if ((self = [super init])) {
        attributes = [[NSMutableArray alloc] init];
        
        program = glCreateProgram();
        
        if (![self compileShader:&vertShader type:GL_VERTEX_SHADER string:vShaderString]) {
            NSLog(@"Failed to compile vertex shader");
        }
        
        if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER string:fShaderString]) {
            NSLog(@"Failed to compile fragment shader");
        }
        
        glAttachShader(program, vertShader);
        glAttachShader(program, fragShader);
    }
    return self;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type string:(NSString *)shaderString {
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[shaderString UTF8String];
    
    if (!source) {
        NSLog(@"Failed to load shader(%@)", shaderString);
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    
    if (status != GL_TRUE) {
        GLint logLength;
		glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0)
		{
			GLchar *log = (GLchar *)malloc(logLength);
			glGetShaderInfoLog(*shader, logLength, &logLength, log);
			NSLog(@"Shader compile log:\n%s", log);
			free(log);
		}
    }
    
    return status == GL_TRUE;
}

- (BOOL)link {
    GLint status;
    
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
        return NO;
    
    if (vertShader)
    {
        glDeleteShader(vertShader);
        vertShader = 0;
    }
    if (fragShader)
    {
        glDeleteShader(fragShader);
        fragShader = 0;
    }
    
    return YES;
}

- (void)use {
    glUseProgram(program);
}

- (void)validate {
    GLint logLength;
	
	glValidateProgram(program);
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(program, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s", log);
		free(log);
	}
}

- (void)addAttribute:(NSString *)attributeName {
    if (![attributes containsObject:attributeName]) {
        [attributes addObject:attributeName];
        glBindAttribLocation(program, (GLuint)[attributes indexOfObject:attributeName], [attributeName UTF8String]);
    }
}

- (GLuint)attributeIndex:(NSString *)attributeName {
    return (GLuint)[attributes indexOfObject:attributeName];
}

- (GLuint)attributeSlot:(NSString *)attributeName {
    return glGetAttribLocation(program, [attributeName UTF8String]);
}

- (GLuint)uniformIndex:(NSString *)uniformName {
    return glGetUniformLocation(program, [uniformName UTF8String]);
}

- (void)dealloc {
    [attributes release];
    
    if (vertShader) {
        glDeleteShader(vertShader);
        vertShader = 0;
    }
    
    if (fragShader) {
        glDeleteShader(fragShader);
        fragShader = 0;
    }
    
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }
    
    [super dealloc];
}

@end
