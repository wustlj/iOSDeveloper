//
//  GLView.h
//  Shader
//
//  Created by lijian on 14-7-7.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>

#import "GPUContext.h"
#import "GPUProgram.h"

@interface GPUView : UIView
{
    CAEAGLLayer *_eaglLayer;
    
    GLuint _frameBuffer;
    GLuint _renderBuffer;
    GLuint _depthBuffer;
    GLuint _outputTexture;
    
    GLuint _positionSlot;
    GLuint _textureSlot;
    GLuint _colorSlot;
    GLuint _modelViewSlot;
    GLuint _projectSlot;
    GLuint _samplerSlot;
    GLuint _samplerSlot2;
    GLuint _colorSlot2;

    GPUProgram *program;
}

@property (nonatomic, assign) GLuint outputTexture;
@property (nonatomic, assign) GLuint outputTexture2;

- (void)draw;

@end
