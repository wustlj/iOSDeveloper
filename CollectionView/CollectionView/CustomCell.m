//
//  CustomCell.m
//  CollectionView
//
//  Created by lijian on 15/11/24.
//  Copyright © 2015年 youku. All rights reserved.
//

#import "CustomCell.h"

@interface CustomCell ()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation CustomCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, frame.size.height - 20)];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        self.contentLabel.font = [UIFont systemFontOfSize:15];
        self.contentLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.contentLabel];
        
        _contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentLabel)]];
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
        UIColor *randomColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        self.backgroundColor = randomColor;
    }
    return self;
}

- (void)setText:(NSString *)text {
    self.contentLabel.text = text;
}

@end
