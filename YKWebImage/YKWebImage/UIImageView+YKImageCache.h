//
//  UIImageView+YKImageCache.h
//  YKWebImage
//
//  Created by lijian on 16/2/25.
//  Copyright © 2016年 youku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (YKImageCache)

- (NSURL *)imageUrl;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completionBlock:(void (^)(void))block;

- (void)cancelImageDownload;

@end
