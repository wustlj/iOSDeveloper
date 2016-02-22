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
typedef void(^YKImageDownloadCompletedBlock)(UIImage *image, BOOL isFinished);

@interface YKImageDownload : NSObject

@property NSInteger maxConcurrentDownloadCount;

- (YKImageDownload *)shareInstance;

- (YKImageDownloadOperation *)downloadImageWithURL:(NSString *)url progress:(YKImageDownloadProgressBlock)progressBlock completed:(YKImageDownloadCompletedBlock)completedBlock;

- (void)setSuspended:(BOOL)suspended;

@end
