//
//  YKCollectionViewCell.m
//  CollectionView
//
//  Created by lijian on 15/11/24.
//  Copyright © 2015年 youku. All rights reserved.
//

#import "YKCollectionViewCell.h"

@implementation YKCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [_draggingDelegate didTouchesBegan:self gestureRecognizer:gesture];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [_draggingDelegate didTouchesMoved:self gestureRecognizer:gesture];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [_draggingDelegate didTouchesEnded:self gestureRecognizer:gesture];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            [_draggingDelegate didTouchesCancel:self gestureRecognizer:gesture];
            break;
        }
        default:
            break;
    }
}

@end
