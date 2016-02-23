//
//  YKImageDownloadOperation.h
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YKImageDownload.h"

@interface YKImageDownloadOperation : NSOperation

@property (nonatomic, strong, readonly) NSURLRequest *request;

- (id)initWithRequest:(NSURLRequest *)request
             progress:(YKImageDownloadProgressBlock)progressBlock
            completed:(YKImageDownloadCompletedBlock)completedBlock;

- (void)cancel;

@end
