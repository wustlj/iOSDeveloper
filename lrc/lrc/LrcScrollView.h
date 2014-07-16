//
//  LrcScrollView.h
//  lrc
//
//  Created by lijian on 14-6-16.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LrcParser.h"

@interface LrcScrollView : UIScrollView
{
    NSMutableArray *cellArray;
    int currentIndex;
    float startTime;
    float startDuration;
}

- (void)setDataSource:(Lrc *)lrc;

- (void)scrollToIndex:(NSInteger)index;

- (void)startCountDown;
- (void)stopCountDown;

@end
