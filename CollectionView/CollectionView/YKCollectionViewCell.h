//
//  YKCollectionViewCell.h
//  CollectionView
//
//  Created by lijian on 15/11/24.
//  Copyright © 2015年 youku. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YKCollectionViewCell;

@protocol YKCollectionViewCellDelegate <NSObject>

- (BOOL)beginInteractiveMovementForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateInteractiveMovementTargetPosition:(CGPoint)targetPosition;
- (void)endInteractiveMovement;
- (void)cancelInteractiveMovement;

- (void)didTouchesBegan:(YKCollectionViewCell *)collectionCell gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)didTouchesMoved:(YKCollectionViewCell *)collectionCell gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)didTouchesEnded:(YKCollectionViewCell *)collectionCell gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)didTouchesCancel:(YKCollectionViewCell *)collectionCell gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;

@end

@interface YKCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<YKCollectionViewCellDelegate> draggingDelegate;

@end
