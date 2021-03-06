//
//  GLView.h
//  Shader
//
//  Created by lijian on 14-7-7.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

#import "GPUOutput.h"

@interface GPUView : UIView <GPUInput>
{
    CAEAGLLayer *_eaglLayer;
    
    GLuint _frameBuffer;
    GLuint _renderBuffer;
    GLuint _depthBuffer;
    GLuint _outputTexture;
    
    GLuint _positionSlot;
    GLuint _textureSlot;
    GLuint _samplerSlot;
    
    GPUProgram *program;
        
    CGSize _size;
    GPUFramebuffer *_inputFramebuffer;
}

@property (nonatomic, assign) GLuint outputTexture;
@property (nonatomic, assign) GLuint outputTexture2;
@property (nonatomic, assign) GLuint maskTexture;

- (void)draw;

@end
