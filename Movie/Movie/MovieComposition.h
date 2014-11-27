//
//  MVComposition.h
//  Movie
//
//  Created by lijian on 14/11/27.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface MovieComposition : NSObject
{
    NSURL *_videoURL;
    CMTimeRange _timeRange;
}

- (id)initWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url timeRange:(CMTimeRange)range;

@property (nonatomic, readonly) NSURL *videoURL;
@property (nonatomic, readonly) CMTimeRange timeRange;

@end
