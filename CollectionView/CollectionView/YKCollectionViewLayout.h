//
//  YKCollectionViewLayout.h
//  CollectionView
//
//  Created by lijian on 15/11/24.
//  Copyright © 2015年 youku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YKCollectionViewLayout : UICollectionViewLayout

@property (nonatomic) CGSize itemSize;

@property (nonatomic) UIEdgeInsets sectionInset;

@property (nonatomic, strong) NSIndexPath *draggingIndexPath;
@property (nonatomic) CGPoint draggingCenter;

- (void)resetDragging;

- (void)swapItemIfNeeded;

@end
