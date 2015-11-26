//
//  ViewController.m
//  CollectionView
//
//  Created by lijian on 15/11/24.
//  Copyright © 2015年 youku. All rights reserved.
//

#import "ViewController.h"

#import "YKCollectionViewLayout.h"
#import "YKCollectionViewCell.h"
#import "CustomCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, YKCollectionViewCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic ,strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray array];
    
    for (int i = 0; i < 10; i++) {
        [self.dataArray addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    YKCollectionViewLayout *layout = [[YKCollectionViewLayout alloc] init];
    layout.itemSize = CGSizeMake(180, 180);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[CustomCell class] forCellWithReuseIdentifier:@"CustomCell"];
    [self.view addSubview:self.collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CustomCell" forIndexPath:indexPath];
    cell.draggingDelegate = self;
    [cell setText:[self.dataArray objectAtIndex:indexPath.item]];
    
    return cell;
}

#pragma mark - Dragging 

- (void)didTouchesBegan:(YKCollectionViewCell *)collectionCell gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:collectionCell];

    [self beginInteractiveMovementForItemAtIndexPath:indexPath];
}

- (void)didTouchesMoved:(YKCollectionViewCell *)collectionCell gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer translationInView:self.collectionView];
    CGPoint originCenter = gestureRecognizer.view.center;
    CGPoint draggingCenter = CGPointMake(originCenter.x + point.x, originCenter.y + point.y);
    
    [gestureRecognizer setTranslation:CGPointZero inView:self.collectionView];
    
    [self updateInteractiveMovementTargetPosition:draggingCenter];
    
    [self scrollIfNeededWhenDraggingCell:collectionCell];
}

- (void)didTouchesEnded:(YKCollectionViewCell *)collectionCell gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    [self endInteractiveMovement];
}

- (void)didTouchesCancel:(YKCollectionViewCell *)collectionCell gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    [self cancelInteractiveMovement];
}


- (BOOL)beginInteractiveMovementForItemAtIndexPath:(NSIndexPath *)indexPath {
    YKCollectionViewLayout *layout = (YKCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    layout.draggingIndexPath = indexPath;
    
    return YES;
}

- (void)updateInteractiveMovementTargetPosition:(CGPoint)targetPosition {
    YKCollectionViewLayout *layout = (YKCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    layout.draggingCenter = targetPosition;
    
    [layout invalidateLayout];
    
    [layout swapItemIfNeeded];
}

- (void)endInteractiveMovement {
    YKCollectionViewLayout *layout = (YKCollectionViewLayout *)self.collectionView.collectionViewLayout;

    [layout resetDragging];
}

- (void)cancelInteractiveMovement {
    [self endInteractiveMovement];
}

#pragma mark - 

- (void)scrollIfNeededWhenDraggingCell:(UICollectionViewCell *)draggingCell {
    YKCollectionViewLayout *layout = (YKCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    if (layout.draggingIndexPath == nil) return;
    
    CGPoint newOffset = self.collectionView.contentOffset;
    CGPoint cellCenter = layout.draggingCenter;

    // down
    CGFloat bottomY = self.collectionView.contentOffset.y + CGRectGetHeight(self.collectionView.frame);
    if (bottomY < CGRectGetMaxY(draggingCell.frame) - 10) {
        newOffset.y += 1;
        
        if (newOffset.y + CGRectGetHeight(self.collectionView.bounds) > self.collectionView.contentSize.height) {
            return; // Stop moving, went too far
        }
        cellCenter.y += 1;
    }
    
    // up
    CGFloat topY = self.collectionView.contentOffset.y;
    if (CGRectGetMinY(draggingCell.frame) + 10 < topY) {
        // We're scrolling up
        newOffset.y -= 1;
        
        if (newOffset.y <= 0) {
            return; // Stop moving, went too far
        }
        
        // adjust cell's center by 1
        cellCenter.y -= 1;
    }
    
    self.collectionView.contentOffset = newOffset;
    layout.draggingCenter = cellCenter;
    [layout invalidateLayout];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollIfNeededWhenDraggingCell:draggingCell];
    });
}

@end
