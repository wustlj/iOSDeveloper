//
//  OpenGLView.h
//  opengl_test_1
//
//  Created by Kalou on 13-5-12.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>

@interface OpenGLView : UIView
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
}
@end
