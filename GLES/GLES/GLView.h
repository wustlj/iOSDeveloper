//
//  GLView.h
//  GLES
//
//  Created by lijian on 14-2-14.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>
#import <QuartzCore/QuartzCore.h>

@interface GLView : UIView
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _renderBuffer;
    GLuint _frameBuffer;
    GLuint _texture;
    GLuint _depthBuffer;
    
    float _angle;
    
    CADisplayLink *_displayLink;
}

- (void)startAnimation;

@end
