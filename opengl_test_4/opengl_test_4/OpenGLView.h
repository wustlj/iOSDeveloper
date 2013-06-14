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
#import <OpenGLES/ES1/glext.h>

// For setting up perspective, define near, far, and angle of view
#define kZNear                          0.01
#define kZFar                           1000.0
#define kFieldOfView                    45.0
// Macros
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define SCREEN_BOUND  ([UIScreen mainScreen].bounds)

@protocol OpenGLViewDelegate
- (void)drawView:(UIView *)theView;
- (void)setupView:(UIView *)theView;
@end

@interface OpenGLView : UIView
{
    EAGLContext *context;
    GLuint viewRenderbuffer, viewFramebuffer;
    GLuint _programHandle;
    GLuint _positionSlot;
}
@property (assign) id<OpenGLViewDelegate> delegate;
@property (nonatomic, readonly) GLuint positionSlot;
- (void)drawView;
@end
