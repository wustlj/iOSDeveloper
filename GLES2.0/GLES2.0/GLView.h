//
//  GLView.h
//  GLES2.0
//
//  Created by lijian on 14-2-18.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>
#import "Shaders.h"
#import "matrix.h"

@interface GLView : UIView
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    
    GLuint _renderBuffer;
    GLuint _depthBuffer;
    GLuint _frameBuffer;
    
    GLuint _texture;
    
    GLuint _program;
    
    int _positionSlot;
    int _colorSlot;
    int _textureSlot;
    int _samplerSlot;
    int _modelViewSlot;
    int _projectSlot;
    
    GLint _width;
    GLint _height;
    GLfloat rotDegree;
    
    CADisplayLink *_link;
}

- (void)startAnimation;

@end
