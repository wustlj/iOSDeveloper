//
//  GLProgram.h
//  Movie
//
//  Created by lijian on 14-7-4.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface GPUProgram : NSObject
{
    GLuint program,
    vertShader, fragShader;
    NSMutableArray  *attributes;
}
- (id)initWithVertexShaderString:(NSString *)vShaderString fragmentShaderString:(NSString *)fShaderString;

- (BOOL)link;
- (void)use;
- (void)validate;

- (void)addAttribute:(NSString *)attributeName;
- (GLuint)attributeIndex:(NSString *)attributeName;
- (GLuint)attributeSlot:(NSString *)attributeName;
- (GLuint)uniformIndex:(NSString *)uniformName;

@end
