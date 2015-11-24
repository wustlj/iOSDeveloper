//
//  YKCollectionViewLayout.m
//  CollectionView
//
//  Created by lijian on 15/11/24.
//  Copyright © 2015年 youku. All rights reserved.
//

#import "YKCollectionViewLayout.h"

@interface YKCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGFloat lineSpacing;

@property (nonatomic) CGRect draggingOriginFrame;

@property (nonatomic, strong) NSMutableDictionary *itemDictionary;

@end

@implementation YKCollectionViewLayout

- (id)init {
    self = [super init];
    if (self) {
        _itemArray = [NSMutableArray array];
        _itemDictionary = [NSMutableDictionary dictionary];
        _lineSpacing = 1.0;
    }
    return self;
}

#pragma mark - Override

- (void)prepareLayout {
    [super prepareLayout];
    
    if (CGSizeEqualToSize(self.itemSize, CGSizeZero)) {
        return;
    }
    
    if ([self.itemArray count] > 0) {
        return;
    }
    
    CGFloat x = self.sectionInset.left;
    CGFloat y = self.sectionInset.top + self.lineSpacing;
    CGFloat w = CGRectGetWidth(self.collectionView.bounds) - self.sectionInset.right;
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    for (int section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (int item = 0; item < itemCount; item++) {
            if (x + self.itemSize.width > w) {
                // 超过边界,需要换行
                x = self.sectionInset.left;
                y += self.itemSize.height + self.lineSpacing;
            }
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:indexPath];
            attribute.frame = CGRectMake(x, y, self.itemSize.width, self.itemSize.height);
            [self.itemArray addObject:attribute];
            [self.itemDictionary setObject:attribute forKey:indexPath];
            
            x += self.itemSize.width + self.lineSpacing;
        }
        
        // 下一个section从新布局
        x = self.sectionInset.left;
        y += self.itemSize.height + self.lineSpacing;
    }
    
    self.contentSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), y);
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *array = [NSMutableArray array];
    
    [[self.itemArray copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UICollectionViewLayoutAttributes *attribute = obj;
        if (CGRectIntersectsRect(attribute.frame, rect)) {
            [self applyDragAttributes:attribute];
            [array addObject:attribute];
        }
    }];
    
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    return attribute;
}

#pragma mark -

- (void)applyDragAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    if ([layoutAttributes.indexPath isEqual:self.draggingIndexPath]) {
        layoutAttributes.center = self.draggingCenter;
        layoutAttributes.zIndex = 100;
    } else {
        layoutAttributes.zIndex = 0;
    }
}

- (void)resetDragging {    
    [self resetFrame];
    
    self.draggingIndexPath = nil;
    
    [self invalidateLayout];
}

- (void)resetFrame {
    CGFloat x = self.sectionInset.left;
    CGFloat y = self.sectionInset.top + self.lineSpacing;
    CGFloat w = CGRectGetWidth(self.collectionView.bounds) - self.sectionInset.right;
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    NSInteger index = 0;
    
    for (int section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (int item = 0; item < itemCount; item++) {
            if (x + self.itemSize.width > w) {
                // 超过边界,需要换行
                x = self.sectionInset.left;
                y += self.itemSize.height + self.lineSpacing;
            }
            
            UICollectionViewLayoutAttributes *attribute = [self.itemArray objectAtIndex:index];
            attribute.frame = CGRectMake(x, y, self.itemSize.width, self.itemSize.height);
            [self.itemArray addObject:attribute];
            
            x += self.itemSize.width + self.lineSpacing;
            index ++;
        }
        
        // 下一个section从新布局
        x = self.sectionInset.left;
        y += self.itemSize.height + self.lineSpacing;
    }
}

@end
