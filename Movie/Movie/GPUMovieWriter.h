//
//  GPUMovieWriter.h
//  Movie
//
//  Created by lijian on 14-10-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@interface GPUMovieWriter : NSObject
{
    AVAssetWriter *_assetWriter;
    AVAssetWriterInput *_audioInput;
    AVAssetWriterInput *_videoInput;
}

- (id)initWithURL:(NSURL *)movieURL size:(CGSize)movieSize;

@end
