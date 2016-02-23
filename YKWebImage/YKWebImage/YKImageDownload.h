//
//  YKImageDownload.h
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YKImageDownloadOperation;

typedef void(^YKImageDownloadProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);
typedef void(^YKImageDownloadCompletedBlock)(UIImage *image, NSError *error, BOOL isFinished);

@interface YKImageDownload : NSObject

@property NSInteger maxConcurrentDownloadCount;
@property NSTimeInterval downloadTimeoutInterval;

+ (YKImageDownload *)shareInstance;

- (YKImageDownloadOperation *)downloadImageWithURL:(NSURL *)url progress:(YKImageDownloadProgressBlock)progressBlock completed:(YKImageDownloadCompletedBlock)completedBlock;

- (void)setSuspended:(BOOL)suspended;

@end
