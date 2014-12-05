//
//  GPUReverseMovie.m
//  Movie
//
//  Created by lijian on 14/12/5.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUReverseMovie.h"

#import <AVFoundation/AVFoundation.h>
#import "GPUOutput.h"
#import "GPUYuvToRgb.h"

@interface GPUReverseMovie ()
{
    GPUYuvToRgb *_yuv2rgb;
    
    AVAssetReader *_assetReader;
    AVAssetReaderTrackOutput *_videoTrackOutput;
    
    CMTime _duration;
    NSInteger _index;
}
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) AVAsset *asset;

@end

@implementation GPUReverseMovie

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
        
        _duration = CMTimeMakeWithEpoch(3000, 600, 0);
        _yuv2rgb = [[GPUYuvToRgb alloc] init];
        
        GLint max;
        glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &max);
        NSLog(@"%d", max);
    }
    return self;
}

- (void)startProcessing {
    [self loadAsset];
}

- (void)loadAsset {
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:self.url options:inputOptions];
    
    typeof(self) __block blockSelf = self;
    
    [inputAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        runSynchronouslyOnVideoProcessingQueue(^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (!tracksStatus == AVKeyValueStatusLoaded)
            {
                return;
            }
            blockSelf.asset = inputAsset;
            [blockSelf processAsset];
            blockSelf = nil;
        });
    }];
}

- (void)processAsset {
    [self createReader];
    
    if (![_assetReader startReading]) {
        NSLog(@"start Reading failed(statue = %d, error = %@)", _assetReader.status, _assetReader.error);
    }
    
    while (_assetReader.status == AVAssetReaderStatusReading) {
        [self readNextVideoFrameFromOutput:_videoTrackOutput];
    }
    
    if (_assetReader.status == AVAssetReaderStatusCompleted) {
        [_assetReader cancelReading];
    }
}

- (void)createReader {
    [_assetReader release];
    _assetReader = nil;
    if (!_assetReader) {
        NSError *error = nil;
        _assetReader = [[AVAssetReader alloc] initWithAsset:_asset error:&error];
        if (error) {
            NSLog(@"%@", [error description]);
            return;
        }
        
        NSArray *videoTracks = [_asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *vTrack = [videoTracks objectAtIndex:0];
        NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        _videoTrackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:vTrack outputSettings:outputSettings];
        
        if ([_assetReader canAddOutput:_videoTrackOutput]) {
            [_assetReader addOutput:_videoTrackOutput];
        }
        _assetReader.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithEpoch(200, 600, 0));
    }
}

- (BOOL)readNextVideoFrameFromOutput:(AVAssetReaderOutput *)readerVideoTrackOutput {
    if (_assetReader.status == AVAssetReaderStatusReading) {
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CMSampleBufferRef bufferRef = [readerVideoTrackOutput copyNextSampleBuffer];
        CFAbsoluteTime currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"Current frame time : %f ms", 1000.0 * currentFrameTime);
        if (bufferRef) {
            
            CMTime movieTime =  CMSampleBufferGetPresentationTimeStamp(bufferRef);
#ifdef DEBUG
            CMTimeShow(movieTime);
#endif
            CVImageBufferRef movieFrame = CMSampleBufferGetImageBuffer(bufferRef);
            
            size_t width = CVPixelBufferGetWidth(movieFrame);
            size_t height = CVPixelBufferGetHeight(movieFrame);
            
            if (_textureSize.height != height || _textureSize.width != width) {
                _textureSize = CGSizeMake(width, height);
            }
            
            if (!_outputFramebuffer) {
                _outputFramebuffer = [[GPUFramebuffer alloc] initWithSize:_textureSize];
            }
            
            [_yuv2rgb processMovieFrame:movieFrame toFramebuffer:_outputFramebuffer];
            
            [self notifyTargetsNewOutputTexture:CMTimeSubtract(_duration, movieTime)];
            
            CMSampleBufferInvalidate(bufferRef);
            CFRelease(bufferRef);
            
            //            if (YES)
            //            {
            //                CFAbsoluteTime currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
            //                NSLog(@"Current frame time : %f ms", 1000.0 * currentFrameTime);
            //            }
            return YES;
        } else {
            if (_assetReader.status == AVAssetReaderStatusCompleted) {
                [self endProcessing];
            }
        }
    }
    return NO;
}

- (void)endProcessing {
    NSLog(@"reverse movie end processing");
    
    for (id<GPUInput> target in _targets) {
        if ([target respondsToSelector:@selector(endProcessing)]) {
            [target endProcessing];
        }
    }
}

@end
