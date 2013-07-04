//
//  OpenGLView.m
//  opengl_test_1
//
//  Created by Kalou on 13-5-12.
//  Copyright (c) 2013年 lijian. All rights reserved.
//

#import "OpenGLView.h"
#import <QuartzCore/QuartzCore.h>


@interface OpenGLView ()
@property (nonatomic, retain) EAGLContext *context;
- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
@end


@implementation OpenGLView

@synthesize context;
@synthesize delegate;
@synthesize rotateColorCube = _rotateColorCube;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
    }
    return self;
}
- (void)setupLayer {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
#if kAttemptToUseOpenGLES2
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (context == NULL)
    {
#endif
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
        }
#if kAttemptToUseOpenGLES2
    }
#endif
}

- (void)drawView
{
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [delegate drawView:self];
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}
- (void)layoutSubviews
{
    [self setupLayer];
    [self setupContext];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}
- (BOOL)createFramebuffer
{
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
        
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    [delegate setupView:self];
    return YES;
}
- (void)destroyFramebuffer
{
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
}

- (void)dealloc
{    
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    [super dealloc];
}

- (void)toggleDisplayLink {
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallBack:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    } else {
        [_displayLink invalidate];
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
}

- (void)displayLinkCallBack:(CADisplayLink*)displayLink
{
    NSLog(@"%f", displayLink.duration);
    _rotateColorCube += displayLink.duration * 90;
    NSLog(@"%f", _rotateColorCube);
    
    [self drawView];
}

@end
