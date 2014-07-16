//
//  LrcScrollView.m
//  lrc
//
//  Created by lijian on 14-6-16.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "LrcScrollView.h"

#define SCROLL_ANIMATION_DURATION 0.5

#define VISIBLE_ROW_NUM 3
#define ROW_COUNT (VISIBLE_ROW_NUM + 1)

@interface LrcScrollView ()
{
    NSTimer *countTimer;
    int _timeCount;
    BOOL _drawing;
}
@property (nonatomic, assign) NSInteger numbersOfDot;
@property (nonatomic, assign) float duation;

@property (nonatomic, retain) NSArray *lrcKeys;
@property (nonatomic, retain) NSArray *lrcValues;

@end

@implementation LrcScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _numbersOfDot = 3;
        _duation = 3.0f;
        currentIndex = -1;
        cellArray = [[NSMutableArray alloc] initWithCapacity:ROW_COUNT];
        
        [self loadViews];
    }
    return self;
}

- (void)dealloc {
    [cellArray release];
    [_lrcKeys release];
    
    [super dealloc];
}

- (void)setDataSource:(Lrc *)lrc {
    self.lrcKeys = [lrc sortedLrcKeys];
    self.lrcValues = [lrc sortedLrcValues];
    
    // 防止第一句歌词开始时间小于3秒
    if ([self.lrcKeys count]) {
        float beginTime = [[self.lrcKeys firstObject] floatValue];
        float defaultTime = 3.0;
        startTime = beginTime > defaultTime ? beginTime - defaultTime : defaultTime;
        startDuration = startTime > defaultTime ? defaultTime: beginTime;
    }
    _duation = startDuration;
    
    [self loadData];
}

- (float)heightForRow {
    return 36.0f;
}

- (UILabel *)cellForRowAtIndex:(NSInteger)index {
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, (4 + [self heightForRow])*index, self.frame.size.width, [self heightForRow])];
    view.textAlignment = NSTextAlignmentCenter;
    view.numberOfLines = 2;
    view.font = [UIFont systemFontOfSize:11.0f];
    view.textColor = [UIColor whiteColor];
    view.backgroundColor = [UIColor clearColor];
    return [view autorelease];
}

- (void)loadViews {
    for (int i = 0; i < ROW_COUNT; i++) {
        UILabel *view = [self cellForRowAtIndex:i];
        [self setContentSize:CGSizeMake(self.frame.size.width, CGRectGetMaxY(view.frame))];
        [cellArray addObject:view];
        
        [self addSubview:view];
    }
}

- (void)loadData {
    for (int i = 2; i < ROW_COUNT; i++) {
        int index = i - 2;
        UILabel *view = [cellArray objectAtIndex:i];
        view.text = [_lrcValues objectAtIndex:index];
    }
}

- (void)scrollViewWithAnimation {
    NSLog(@"time:%@", [_lrcKeys objectAtIndex:currentIndex]);
    
    float duration = [self animationDuration];
    
    if (duration >= SCROLL_ANIMATION_DURATION) {
        [UIView animateWithDuration:duration animations:^{
            [self beforeScroll];
            [self scrollSubViews];
        } completion:^(BOOL finished) {
            if (finished) {
                [self reloadTopView];
            }
        }];
    } else {
        [self scrollSubViews];
        
        [self reloadTopView];
    }
}

- (NSString *)lrcStringWithIndex:(NSInteger)index {
    if (index < [_lrcKeys count]) {
        return [_lrcValues objectAtIndex:index];
    }
    return nil;
}

- (void)beforeScroll {
    int index = (1 + currentIndex) % ROW_COUNT;
    UILabel *view = [cellArray objectAtIndex:index];
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont systemFontOfSize:11.0f];
    
    int index2 = (2 + currentIndex) % ROW_COUNT;
    UILabel *view2 = [cellArray objectAtIndex:index2];
    view2.textColor = [UIColor blueColor];
    view2.font = [UIFont systemFontOfSize:15.0f];
}

- (void)scrollSubViews {
    for (int i = 0; i < ROW_COUNT; i++) {
        int index = (i + currentIndex) % ROW_COUNT;
        UILabel *view = [cellArray objectAtIndex:index];
        view.frame = CGRectMake(0, (4 + [self heightForRow]) * (i-1), self.frame.size.width, [self heightForRow]);
    }
}

- (void)reloadTopView {
    int i = 0;
    int index = (i + currentIndex) % ROW_COUNT;
    UILabel *view = [cellArray objectAtIndex:index];
    view.frame = CGRectMake(0, (4 + [self heightForRow]) * VISIBLE_ROW_NUM, self.frame.size.width, [self heightForRow]);
    view.text = [self lrcStringWithIndex:(currentIndex + VISIBLE_ROW_NUM - 1)];
}

- (float)animationDuration {
    float duration = SCROLL_ANIMATION_DURATION;
    if ((currentIndex + 1) < [_lrcKeys count]) {
        duration = [[_lrcKeys objectAtIndex:(currentIndex + 1)] floatValue] - [[_lrcKeys objectAtIndex:currentIndex] floatValue];
    }
    duration = (duration >= SCROLL_ANIMATION_DURATION) ? SCROLL_ANIMATION_DURATION : duration;
    return duration;
}

- (void)scrollToIndex:(NSInteger)index {
    if (currentIndex == index || currentIndex == [_lrcKeys count]) {
        return;
    }
    currentIndex = index;
    
    NSLog(@">>>>%d", currentIndex);
    
    [self scrollViewWithAnimation];
}

#pragma mark - CountDown


- (void)drawRect:(CGRect)rect {
    NSLog(@"%d", _timeCount);
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    if (!_drawing) {
        return;
    }
    
    int blueArcCount = _timeCount;
    int whiteArcCount = _numbersOfDot - _timeCount;
    
    CGFloat radius = 3.0;
    
    for (int i = 0; i < blueArcCount; i++) {
        drawArc(context, CGPointMake(40 + radius + (2*radius + 5)*i, (4 + [self heightForRow]) + 10 + radius), radius, 0, 2 * M_PI, 0.0, 0.0, 1.0);
    }
    
    for (int i = 0; i < whiteArcCount; i++) {
        drawArc(context, CGPointMake(40 + radius + (2*radius + 5)*i + (2*radius + 5)*blueArcCount, (4 + [self heightForRow]) + 10 + radius), radius, 0, 2 * M_PI, 1.0, 1.0, 1.0);
    }
}

- (void)startCountDown {
    [self stopCountDown];
    
    _drawing = YES;
    countTimer = [NSTimer scheduledTimerWithTimeInterval:_duation/_numbersOfDot target:self selector:@selector(countDownAction) userInfo:nil repeats:YES];
    [countTimer fire];
}

- (void)countDownAction {
    _timeCount ++;
    
    if(_timeCount > _numbersOfDot) {
        [self stopCountDown];
    }
    
    [self setNeedsDisplay];
}

- (void)stopCountDown {
    _timeCount = 0;
    _drawing = NO;
    if (countTimer && [countTimer isValid]) {
        [countTimer invalidate];
        countTimer = nil;
    }
}

static inline void drawArc(CGContextRef ctx, CGPoint point, CGFloat radius, float angle_start, float angle_end, CGFloat red, CGFloat green, CGFloat blue) {
    CGContextMoveToPoint(ctx, point.x, point.y);
    CGContextSetRGBFillColor(ctx, red, green, blue, 1.0);
    CGContextAddArc(ctx, point.x, point.y, radius,  angle_start, angle_end, 0);
    CGContextFillPath(ctx);
}

@end
