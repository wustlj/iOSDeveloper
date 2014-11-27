//
//  GPUMultiMovie.m
//  Movie
//
//  Created by lijian on 14/11/13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUMultiMovie.h"

#import "GPUOutput.h"
#import "GPUYuvToRgb.h"

#import "MovieComposition.h"

extern NSString *const kYUVVertexShaderString;
extern NSString *const kYUVVideoRangeConversionForLAFragmentShaderString;

@interface GPUMultiMovie ()
{
    NSArray *_videos;
    NSMutableDictionary *_assets;
    
    GPUYuvToRgb *_yuv2rgb;
    
    AVAssetReader *_assetReader;
    AVAssetReaderTrackOutput *_videoTrackOutput;
    
    NSInteger _processingIndex;
    CMTime  _baseTime;
    CMTime _frameTime;
}
@end

@implementation GPUMultiMovie

- (id)initWithVideos:(NSArray *)videos {
    self = [super init];
    if (self) {
        _videos = [[NSArray alloc] initWithArray:videos];
        _assets = [[NSMutableDictionary alloc] initWithCapacity:[videos count]];
        
        [self commonInit];
    }
    return self;
}

- (id)initWithVideos:(NSArray *)videos withAssets:(NSMutableDictionary *)assets {
    self = [super init];
    if (self) {
        _videos = [videos retain];
        _assets = [assets retain];
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _processingIndex = 0;
    _baseTime = CMTimeMakeWithSeconds(0, 600);
    _frameTime = CMTimeMakeWithEpoch(20, 600, 0);
    
    _yuv2rgb = [[GPUYuvToRgb alloc] init];
}

- (void)dealloc
{
    [_videos release];
    [_assets release];
    [_assetReader release];
    [_videoTrackOutput release];
    
    [_yuv2rgb release];
    [_outputFramebuffer release];
    
    [super dealloc];
}

- (void)load
{
    dispatch_group_t group = dispatch_group_create();

    for (MovieComposition *c in _videos) {
        if ([[_assets allKeys] containsObject:[c.videoURL absoluteString]]) {
            continue;
        }
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:c.videoURL options:inputOptions];
        
        [_assets setObject:inputAsset forKey:[c.videoURL absoluteString]];
        
        dispatch_group_enter(group);
        [inputAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (!tracksStatus == AVKeyValueStatusLoaded)
            {
                NSLog(@"<Warning>Load (%@) tracks failed", _assets);
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        dispatch_release(group);
        NSLog(@"all loaded");
    });
}

- (void)startProcessing
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        runSynchronouslyOnVideoProcessingQueue(^{
            for (MovieComposition *c in _videos) {
                AVAsset *asset = [_assets objectForKey:[c.videoURL absoluteString]];
                [self processAsset:asset withTimeRange:c.timeRange];
            }
        });
    });
}

- (void)processAsset:(AVAsset *)asset withTimeRange:(CMTimeRange)range {
    [self createReader:asset withTimeRange:range];
    
    if ([_assetReader startReading]) {
        NSLog(@"%ld", (long)_assetReader.status);
    }
    
    while (_assetReader.status == AVAssetReaderStatusReading) {
        [self readNextVideoFrameFromOutput:_videoTrackOutput];
    }
    
    if (_assetReader.status == AVAssetReaderStatusCompleted) {
        [_assetReader cancelReading];
    }
}

- (void)createReader:(AVAsset *)asset {
    [self createReader:asset withTimeRange:kCMTimeRangeZero];
}

- (void)createReader:(AVAsset *)asset withTimeRange:(CMTimeRange)range {
    [_assetReader release];
    _assetReader = nil;
    if (!_assetReader) {
        NSError *error = nil;
        _assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        if (error) {
            NSLog(@"%@", [error description]);
            return;
        }
        
        NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *vTrack = [videoTracks objectAtIndex:0];
        NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        [_videoTrackOutput release];
        _videoTrackOutput = nil;
        _videoTrackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:vTrack outputSettings:outputSettings];
        
        if ([_assetReader canAddOutput:_videoTrackOutput]) {
            [_assetReader addOutput:_videoTrackOutput];
        }
        if (!CMTimeRangeEqual(range, kCMTimeRangeZero)) {
            _assetReader.timeRange = range;
        }
    }
}

- (BOOL)readNextVideoFrameFromOutput:(AVAssetReaderOutput *)readerVideoTrackOutput {
    if (_assetReader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef bufferRef = [readerVideoTrackOutput copyNextSampleBuffer];
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
            
            [self notifyTargetsNewOutputTexture:_baseTime];
            _baseTime = CMTimeAdd(_baseTime, _frameTime);

            CMSampleBufferInvalidate(bufferRef);
            CFRelease(bufferRef);
            return YES;
        } else {
            if (_assetReader.status == AVAssetReaderStatusCompleted) {
                [self currentMovieProcessFinished];
            }
        }
    }
    return NO;
}

- (void)currentMovieProcessFinished
{
    NSLog(@"%d finished", _processingIndex);
    _processingIndex++;
    
    if (_processingIndex == [_videos count]) {
        NSLog(@"all movie finished");
        
        [self endProcessing];
        
        _baseTime = CMTimeMakeWithSeconds(0, 600);
        _processingIndex = 0;
    }
}

- (void)endProcessing {
    NSLog(@"movie end processing");
    
    for (id<GPUInput> target in _targets) {
        if ([target respondsToSelector:@selector(endProcessing)]) {
            [target endProcessing];
        }
    }
}

@end
