//
//  MVComposition.m
//  Movie
//
//  Created by lijian on 14/11/27.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "MovieComposition.h"

@implementation MovieComposition

- (id)initWithURL:(NSURL *)url
{
    return [self initWithURL:url timeRange:kCMTimeRangeZero];
}

- (id)initWithURL:(NSURL *)url timeRange:(CMTimeRange)range
{
    self = [super init];
    if (self) {
        _timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
        
        _videoURL = [url retain];
        if (!CMTIMERANGE_IS_EMPTY(range)) {
            _timeRange = range;
        }
    }
    return self;
}

- (void)dealloc
{
    [_videoURL release];
    
    [super dealloc];
}

@end
