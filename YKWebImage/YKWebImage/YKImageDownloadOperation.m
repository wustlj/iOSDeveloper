//
//  YKImageDownloadOperation.m
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import "YKImageDownloadOperation.h"

@interface YKImageDownloadOperation () <NSURLConnectionDataDelegate>

@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

@property (nonatomic, copy) YKImageDownloadProgressBlock progressBlock;
@property (nonatomic, copy) YKImageDownloadCompletedBlock completedBlock;

@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *receivedData;

@end

@implementation YKImageDownloadOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

- (id)initWithRequest:(NSURLRequest *)request progress:(YKImageDownloadProgressBlock)progressBlock completed:(YKImageDownloadCompletedBlock)completedBlock {
    self = [super init];
    if (self) {
        _request = request;
        _progressBlock = [progressBlock copy];
        _completedBlock = [completedBlock copy];
        
    }
    return self;
}

- (void)start {
    @synchronized(self) {
        if (self.isCancelled) {
            self.finished = YES;
            return;
        }
        
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    }
    
    [self.urlConnection start];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_completedBlock) {
        UIImage *image = [UIImage imageWithData:self.receivedData];
        _completedBlock(image, YES);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.receivedData = nil;
}

@end
