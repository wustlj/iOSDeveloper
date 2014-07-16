//
//  LrcStartView.m
//  lrc
//
//  Created by lijian on 14-6-18.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "LrcStartView.h"

#define degreesToRadian(x) (M_PI * x / 180.0)

@interface LrcStartView ()
{
    NSTimer *_countDownTimer;
    int _count;
}
@end


@implementation LrcStartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _numbersOfDot = 3;
        _duation = 3.0f;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    [self stopTimer];
    
    [super dealloc];
}

- (void)startAnimation {
    [self stopTimer];
    [self startTimer];
}

- (void)stopAnimation {
    _count = 0;
    [self stopTimer];
}

- (void)startTimer {
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:_duation/_numbersOfDot target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [_countDownTimer fire];
}

- (void)stopTimer {
    if (_countDownTimer && [_countDownTimer isValid]) {
        [_countDownTimer invalidate];
        _countDownTimer = nil;
    }
}

- (void)timerAction {
    _count++;
    
    if (_count >_numbersOfDot) {
        _count = 0;
        [self stopTimer];
        return;
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"%d", _count);
    
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    int blueArcCount = _count;
    int whiteArcCount = _numbersOfDot - _count;
    
    for (int i = 0; i < blueArcCount; i++) {
        drawArc(context, CGPointMake(3 + 11*i, 3), 3, 0, 2 * M_PI, 0.0, 0.0, 1.0);
    }
    
    for (int i = 0; i < whiteArcCount; i++) {
        drawArc(context, CGPointMake(3 + 11*i + 11*blueArcCount, 3), 3, 0, 2 * M_PI, 1.0, 1.0, 1.0);
    }
}

static inline void drawArc(CGContextRef ctx, CGPoint point, CGFloat radius, float angle_start, float angle_end, CGFloat red, CGFloat green, CGFloat blue) {
    CGContextMoveToPoint(ctx, point.x, point.y);
    CGContextSetRGBFillColor(ctx, red, green, blue, 1.0);
    CGContextAddArc(ctx, point.x, point.y, radius,  angle_start, angle_end, 0);
    //CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

@end
