//
//  LrcStartView.h
//  lrc
//
//  Created by lijian on 14-6-18.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LrcStartView : UIView

@property (nonatomic, assign) NSInteger numbersOfDot;
@property (nonatomic, assign) float duation;

- (void)startAnimation;
- (void)stopAnimation;

@end
