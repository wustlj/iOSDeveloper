//
//  YKImageCache.h
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YKImageCache : NSObject

@property(nonatomic, assign) BOOL shouldCacheInMemory;

- (YKImageCache *)shareInstance;

@end
