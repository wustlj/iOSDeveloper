//
//  YKImageDownloadOperation.m
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import "YKImageDownloadOperation.h"

@interface YKImageDownloadOperation ()

@property (nonatomic, copy) YKImageDownloadProgressBlock progressBlock;
@property (nonatomic, copy) YKImageDownloadCompletedBlock completedBlock;

@end

@implementation YKImageDownloadOperation

- (id)initWithRequest:(NSURLRequest *)request progress:(YKImageDownloadProgressBlock)progressBlock completed:(YKImageDownloadCompletedBlock)completedBlock {
    self = [super init];
    if (self) {
        _request = request;
        _progressBlock = [progressBlock copy];
        _completedBlock = [completedBlock copy];
    }
    return self;
}

@end
