//
//  GPUMutilMovie.m
//  Movie
//
//  Created by lijian on 14/11/13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUMutilMovie.h"

#import "GPUOutput.h"

extern NSString *const kYUVVertexShaderString;
extern NSString *const kYUVVideoRangeConversionForLAFragmentShaderString;
extern const GLfloat kColorConversion601FullRange[];

@interface GPUMutilMovie ()
{
    NSArray *_videos;
    
    AVAssetReader *_assetReader;
    AVAssetReaderTrackOutput *_videoTrackOutput;
    
    int imageBufferWidth, imageBufferHeight;
    
    GLuint _luminanceTexture, _chrominanceTexture;
    CVOpenGLESTextureCacheRef _textureCacheRef;
    GPUProgram *_yuvConversionProgram;
    GLuint _yuvConversionPositionAttribute, _yuvConversionTextureCoordinateAttribute;
    GLint _yuvConversionLuminanceTextureUniform, _yuvConversionChrominanceTextureUniform;
    GLint _yuvConversionMatrixUniform;
    
    NSInteger _processingIndex;
}
@end

@implementation GPUMutilMovie

- (id)initWithVideos:(NSArray *)videos {
    self = [super init];
    if (self) {
        _videos = [[NSArray alloc] initWithArray:videos];
        _processingIndex = 0;
        
        _textureCacheRef = [[GPUContext sharedImageProcessingContext] coreVideoTextureCache];
        [self setupYUVProgram];
    }
    return self;
}

- (void)dealloc
{
    [_videos release];
    [_assetReader release];
    [_videoTrackOutput release];
    
    [_yuvConversionProgram release];
    [_outputFramebuffer release];
    
    [super dealloc];
}


- (AVURLAsset *)loadMovieTracks:(NSURL *)url completionHandler:(void (^)(void))handler
{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:inputOptions];
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        runSynchronouslyOnVideoProcessingQueue(^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [asset statusOfValueForKey:@"tracks" error:&error];
            if (!tracksStatus == AVKeyValueStatusLoaded)
            {
                return;
            }
            handler();
        });
    }];
    return asset;
}

- (void)startProcessing
{
//    for (MovieCompositon *c in _videos) {
//        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
//        AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:c.videoURL options:inputOptions];
//        
//        typeof(self) __block blockSelf = self;
//        
//        [inputAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
//            runSynchronouslyOnVideoProcessingQueue(^{
//                NSError *error = nil;
//                AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
//                if (!tracksStatus == AVKeyValueStatusLoaded)
//                {
//                    return;
//                }
//                [blockSelf processAsset:inputAsset];
//                blockSelf = nil;
//            });
//        }];
//    }

    if (_processingIndex < [_videos count]) {
        MovieCompositon *c = [_videos objectAtIndex:_processingIndex];
        [self processingMovie:c];
    } else {
        NSLog(@"all finished");
        _processingIndex = 0;
    }
}

- (void)processingMovie:(MovieCompositon *)composition
{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:composition.videoURL options:inputOptions];
    
    typeof(self) __block blockSelf = self;
    
    [inputAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        runSynchronouslyOnVideoProcessingQueue(^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (!tracksStatus == AVKeyValueStatusLoaded)
            {
                return;
            }
            [blockSelf processAsset:inputAsset];
            blockSelf = nil;
        });
    }];
}

- (void)currentMovieProcessFinished
{
    NSLog(@"%d finished", _processingIndex);
    _processingIndex++;
    
    [self startProcessing];
}

- (void)processAsset:(AVAsset *)asset {
    [self createReader:asset];
    
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
    }
}

- (BOOL)readNextVideoFrameFromOutput:(AVAssetReaderOutput *)readerVideoTrackOutput {
    if (_assetReader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef bufferRef = [readerVideoTrackOutput copyNextSampleBuffer];
        if (bufferRef) {
#ifdef DEBUG
            CMTime movieTime =  CMSampleBufferGetPresentationTimeStamp(bufferRef);
            CMTimeShow(movieTime);
#endif
            CVImageBufferRef movieFrame = CMSampleBufferGetImageBuffer(bufferRef);
            [self processMovieFrame:movieFrame withSampleTime:movieTime];
            CMSampleBufferInvalidate(bufferRef);
            CFRelease(bufferRef);
            
            return YES;
        } else {
            if (_assetReader.status == AVAssetReaderStatusCompleted) {
//                [self endProcessing];
                [self currentMovieProcessFinished];
            }
        }
    }
    return NO;
}

- (void)processMovieFrame:(CVPixelBufferRef)movieFrame withSampleTime:(CMTime)sampleTime {
    CVPixelBufferLockBaseAddress(movieFrame, 0);
    size_t width = CVPixelBufferGetWidth(movieFrame);
    size_t height = CVPixelBufferGetHeight(movieFrame);
    
    if (imageBufferHeight != height || imageBufferWidth != width) {
        imageBufferHeight = (int)height;
        imageBufferWidth = (int)width;
        _textureSize = CGSizeMake(imageBufferWidth, imageBufferHeight);
    }
    
    glActiveTexture(GL_TEXTURE4);
    CVOpenGLESTextureRef yPlaneTextureOut = NULL;
    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCacheRef, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, imageBufferWidth, imageBufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &yPlaneTextureOut);
    _luminanceTexture = CVOpenGLESTextureGetName(yPlaneTextureOut);
    glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glActiveTexture(GL_TEXTURE5);
    CVOpenGLESTextureRef uvPlaneTextureOut = NULL;
    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCacheRef, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, imageBufferWidth/2, imageBufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &uvPlaneTextureOut);
    _chrominanceTexture = CVOpenGLESTextureGetName(uvPlaneTextureOut);
    glBindTexture(GL_TEXTURE_2D, _chrominanceTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    [self convertYUVToRGBOutput];
    
    [self notifyTargetsNewOutputTexture:sampleTime];
    
    CFRelease(yPlaneTextureOut);
    CFRelease(uvPlaneTextureOut);
    
    CVPixelBufferUnlockBaseAddress(movieFrame, 0);
    
    CVOpenGLESTextureCacheFlush(_textureCacheRef, 0);
}

- (void)endProcessing {
    NSLog(@"movie end processing");
    
    for (id<GPUInput> target in _targets) {
        if ([target respondsToSelector:@selector(endProcessing)]) {
            [target endProcessing];
        }
    }
}

#pragma mark - GPU

- (void)setupYUVProgram {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUContext useImageProcessingContext];
        
        _yuvConversionProgram = [[[GPUContext sharedImageProcessingContext] programForVertexShaderString:kYUVVertexShaderString fragmentShaderString:kYUVVideoRangeConversionForLAFragmentShaderString] retain];
        
        [_yuvConversionProgram addAttribute:@"position"];
        [_yuvConversionProgram addAttribute:@"inputTextureCoordinate"];
        
        if (![_yuvConversionProgram link]) {
            NSLog(@"yuvConversionProgram link fail");
        };
        
        _yuvConversionPositionAttribute = [_yuvConversionProgram attributeIndex:@"position"];
        _yuvConversionTextureCoordinateAttribute = [_yuvConversionProgram attributeIndex:@"inputTextureCoordinate"];
        _yuvConversionLuminanceTextureUniform = [_yuvConversionProgram uniformIndex:@"luminanceTexture"];
        _yuvConversionChrominanceTextureUniform = [_yuvConversionProgram uniformIndex:@"chrominanceTexture"];
        _yuvConversionMatrixUniform = [_yuvConversionProgram uniformIndex:@"colorConversionMatrix"];
        
        [GPUContext setActiveShaderProgram:_yuvConversionProgram];
        
        glEnableVertexAttribArray(_yuvConversionPositionAttribute);
        glEnableVertexAttribArray(_yuvConversionTextureCoordinateAttribute);
    });
}

- (void)convertYUVToRGBOutput {
    [GPUContext setActiveShaderProgram:_yuvConversionProgram];
    
    if (!_outputFramebuffer) {
        _outputFramebuffer = [[GPUFramebuffer alloc] initWithSize:CGSizeMake(imageBufferWidth, imageBufferHeight)];
    }
    
    [_outputFramebuffer activateFramebuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    static const GLfloat squarVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureCoordies[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat kColor601FullRange[] = {
        1.0,    1.0,    1.0,
        0.0,    -0.343, 1.765,
        1.4,    -0.711, 0.0,
    };
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
    glUniform1i(_yuvConversionLuminanceTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, _chrominanceTexture);
    glUniform1i(_yuvConversionChrominanceTextureUniform, 5);
    
    glUniformMatrix3fv(_yuvConversionMatrixUniform, 1, GL_FALSE, kColor601FullRange);
    
    glVertexAttribPointer(_yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squarVertices);
    glVertexAttribPointer(_yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordies);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (GLuint)outputTexture {
    return _outputFramebuffer.texture;
}

@end

@implementation MovieCompositon

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
        if (!CMTimeRangeEqual(range, kCMTimeRangeZero)) {
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
