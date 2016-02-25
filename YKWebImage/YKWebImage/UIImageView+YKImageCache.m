//
//  UIImageView+YKImageCache.m
//  YKWebImage
//
//  Created by lijian on 16/2/25.
//  Copyright © 2016年 youku. All rights reserved.
//

#import "UIImageView+YKImageCache.h"
#import <objc/runtime.h>
#import "YKImageCache.h"
#import "YKImageDownload.h"

static char imageURLKey;

@implementation UIImageView (YKImageCache)

- (NSURL *)imageUrl {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder  {
    [self setImageWithURL:url placeholderImage:placeholder completionBlock:NULL];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completionBlock:(void (^)(void))block {
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.image = placeholder;
    
    if (url) {
        UIImage *image = [[YKImageCache shareInstance] imageFromCacheForKey:[url absoluteString]];
        
        if (!image) {
            __weak __typeof(self) wself = self;
            [[YKImageDownload shareInstance] downloadImageWithURL:url progress:NULL completed:^(UIImage *image, NSError *error, BOOL isFinished) {
                if (!wself) return ;
                
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image = image;
                    });
                    
                    [[YKImageCache shareInstance] storeImage:image forKey:[url absoluteString]];
                    
                    if (block) {
                        block();
                    }
                }
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
            });
        }
    }
}

- (void)cancelImageDownload {
    
}

@end
