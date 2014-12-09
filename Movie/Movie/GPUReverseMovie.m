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

#define FRAGMENT_TIME 300.0f

@interface GPUReverseMovie ()
{
    GPUYuvToRgb *_yuv2rgb;
    
    AVAssetReader *_assetReader;
    AVAssetReaderTrackOutput *_videoTrackOutput;
    
    CMTime _duration;
    NSInteger _index;
    NSMutableArray *_framebufferArray;
    
    CMTime _baseTime;
}
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) AVAsset *asset;

@end

@implementation GPUReverseMovie

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
        
        _yuv2rgb = [[GPUYuvToRgb alloc] init];
        
        _framebufferArray = [[NSMutableArray alloc] init];
        _baseTime = CMTimeMakeWithEpoch(0, 600, 0);
    }
    return self;
}

- (void)dealloc {
    [_url release];
    [_asset release];
    [_yuv2rgb release];
    [_framebufferArray release];
    [_assetReader release];
    [_videoTrackOutput release];
    
    [super dealloc];
}

- (void)startProcessing {
    [self loadAsset];
}

- (void)loadAsset {
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:self.url options:inputOptions];
    self.asset = inputAsset;
    
    typeof(self) __block blockSelf = self;
    
    [inputAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        runSynchronouslyOnVideoProcessingQueue(^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (!tracksStatus == AVKeyValueStatusLoaded)
            {
                return;
            }
            
            [blockSelf processAssetFragment];
            blockSelf = nil;
        });
    }];
}

- (void)processAssetFragment {
    CMTime duration = [self.asset duration];
    CMTime scaleDuration = CMTimeConvertScale(duration, 600, kCMTimeRoundingMethod_Default);
    
    int value = (int)scaleDuration.value;
    int count = ceil(value/FRAGMENT_TIME);
    
    for (int i = count - 1; i >= 0; i--) {
        CMTime et = CMTimeMakeWithEpoch(FRAGMENT_TIME * (i + 1), 600, 0);
        CMTime st = CMTimeMakeWithEpoch(FRAGMENT_TIME * i, 600, 0);
        
        CMTimeRange range = CMTimeRangeFromTimeToTime(st, et);
        
        _index = i;
        
        [self processAsset:range];
    }
}

- (void)processAsset:(CMTimeRange)range {
    [self createReader:range];
    
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

- (void)createReader:(CMTimeRange)range {
    [_assetReader release];
    _assetReader = nil;
    if (!_assetReader) {
        NSError *error = nil;
        _assetReader = [[AVAssetReader alloc] initWithAsset:_asset error:&error];
        if (error) {
            NSLog(@"%@", [error description]);
            return;
        }
        
        [_videoTrackOutput release];
        _videoTrackOutput = nil;
        if (!_videoTrackOutput) {
            NSArray *videoTracks = [_asset tracksWithMediaType:AVMediaTypeVideo];
            AVAssetTrack *vTrack = [videoTracks objectAtIndex:0];
            NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
            _videoTrackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:vTrack outputSettings:outputSettings];
        }
        
        if ([_assetReader canAddOutput:_videoTrackOutput]) {
            [_assetReader addOutput:_videoTrackOutput];
        }
        _assetReader.timeRange = range;
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
                _outputFramebuffer = [[GPUFramebuffer alloc] initOnlyTextureWithSize:_textureSize];
            }
            
            GPUFramebuffer *fb = [[GPUFramebuffer alloc] initOnlyTextureWithSize:_textureSize];
            
            [_yuv2rgb processMovieFrame:movieFrame toFramebuffer:fb];
            
            [_framebufferArray addObject:fb];
            
            [fb release];
            
//            [self notifyTargetsNewOutputTexture:CMTimeSubtract(_duration, movieTime)];
            
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
    NSLog(@"reading movie range end");
    
    [self writeFramebuffer];
    
    if (_index == 0) {
        for (id<GPUInput> target in _targets) {
            if ([target respondsToSelector:@selector(endProcessing)]) {
                [target endProcessing];
            }
        }
    }
}

- (void)writeFramebuffer {
    int num = (int)[_framebufferArray count];
    
    for (int i = num - 1; i >= 0; i--) {
        GPUFramebuffer *fb = _framebufferArray[i];
        [self notifyTargetsNewOutputTexture:_baseTime withFramebuffer:fb];
        
        _baseTime = CMTimeAdd(_baseTime, CMTimeMakeWithEpoch(20, 600, 0));
    }
    
    [_framebufferArray removeAllObjects];
}

@end
