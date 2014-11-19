//
//  GPUMultiMovie.h
//  Movie
//
//  Created by lijian on 14/11/13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "GPUOutput.h"

@interface GPUMultiMovie : GPUOutput

- (id)initWithVideos:(NSArray *)videos;

- (void)load;
- (void)startProcessing;

@end


@interface MovieCompositon : NSObject
{
    NSURL *_videoURL;
    CMTimeRange _timeRange;
}

- (id)initWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url timeRange:(CMTimeRange)range;

@property (nonatomic, readonly) NSURL *videoURL;
@property (nonatomic, readonly) CMTimeRange timeRange;

@end