//
//  GPUMovie.m
//  Movie
//
//  Created by lijian on 14-7-16.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUMovie.h"

// Color Conversion Constants (YUV to RGB) including adjustment from 16-235/16-240 (video range)

// BT.601, which is the standard for SDTV.
const GLfloat kColorConversion601[] = {
    1.164,  1.164, 1.164,
    0.0, -0.392, 2.017,
    1.596, -0.813,   0.0,
};

// BT.709, which is the standard for HDTV.
const GLfloat kColorConversion709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

// BT.601 full range (ref: http://www.equasys.de/colorconversion.html)
const GLfloat kColorConversion601FullRange[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};

NSString *const kYUVVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

NSString *const kYUVVideoRangeConversionForLAFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D luminanceTexture;
 uniform sampler2D chrominanceTexture;
 uniform mediump mat3 colorConversionMatrix;
 
 void main()
 {
     mediump vec3 yuv;
     lowp vec3 rgb;
     
     yuv.x = texture2D(luminanceTexture, textureCoordinate).r;
     yuv.yz = texture2D(chrominanceTexture, textureCoordinate).ra - vec2(0.5, 0.5);
     rgb = colorConversionMatrix * yuv;
     
     gl_FragColor = vec4(rgb, 1);
 }
 );

@implementation GPUMovie

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
        _targets = [[NSMutableArray alloc] init];
        
        [self commInit];
        
        [self setupYUVProgram];
        
        _textureCacheRef = [[GPUContext sharedImageProcessingContext] coreVideoTextureCache];
    }
    return self;
}

- (void)commInit {
    _keepLooping = YES;
    _textureIndex = 0;
}

- (void)dealloc {
    [_url release];
    [_asset release];
    [_assetReader release];
    [_videoTrackOutput release];
    
    [_yuvConversionProgram release];
    
    Block_release(_completionBlock);
    
    [_yuvConversionFrameBuffer release];
    
    [self removeAllTargets];
    
    [super dealloc];
}

#pragma mark - Movie

- (void)startProcessing {
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
    
    if ([_assetReader startReading]) {
        NSLog(@"%ld", (long)_assetReader.status);
    }
    
    if (_keepLooping) {
        while (_assetReader.status == AVAssetReaderStatusReading) {
            [self readNextVideoFrameFromOutput:_videoTrackOutput];
        }
        
        if (_assetReader.status == AVAssetReaderStatusCompleted) {
            [_assetReader cancelReading];
        }
    }
}

- (BOOL)readNextVideoFrame {    
    return [self readNextVideoFrameFromOutput:_videoTrackOutput];
}

- (BOOL)readNextVideoFrameFromOutput:(AVAssetReaderOutput *)readerVideoTrackOutput {
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
    } else {
        if (_assetReader.status == AVAssetReaderStatusCompleted) {
            [self endProcessing];
        }
    }
    return YES;
}

- (void)processMovieFrame:(CVPixelBufferRef)movieFrame withSampleTime:(CMTime)sampleTime {
    CVPixelBufferLockBaseAddress(movieFrame, 0);
    size_t width = CVPixelBufferGetWidth(movieFrame);
    size_t height = CVPixelBufferGetHeight(movieFrame);
    
    if (imageBufferHeight != height || imageBufferWidth != width) {
        imageBufferHeight = (int)height;
        imageBufferWidth = (int)width;
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
    
    if (_completionBlock) {
        _completionBlock();
    }
    
    [self informTargetsNewFrame:sampleTime];
    
    CFRelease(yPlaneTextureOut);
    CFRelease(uvPlaneTextureOut);
    
    CVPixelBufferUnlockBaseAddress(movieFrame, 0);
    
    CVOpenGLESTextureCacheFlush(_textureCacheRef, 0);
}

- (void)endProcessing {
    NSLog(@"end processing");
    
    for (id<GPUInput> target in _targets) {
        if ([target respondsToSelector:@selector(endProcessing)]) {
            [target endProcessing];
        }
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
        AVAssetTrack *track = [videoTracks objectAtIndex:0];
        NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        _videoTrackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:outputSettings];
        
        if ([_assetReader canAddOutput:_videoTrackOutput]) {
            [_assetReader addOutput:_videoTrackOutput];
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
    
    if (!_yuvConversionFrameBuffer) {
        _yuvConversionFrameBuffer = [[GPUFramebuffer alloc] initWithSize:CGSizeMake(imageBufferWidth, imageBufferHeight)];
    }
    
    [_yuvConversionFrameBuffer activateFramebuffer];
    
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
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
    glUniform1i(_yuvConversionLuminanceTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, _chrominanceTexture);
    glUniform1i(_yuvConversionChrominanceTextureUniform, 5);
    
    glUniformMatrix3fv(_yuvConversionMatrixUniform, 1, GL_FALSE, kColorConversion601FullRange);
    
    glVertexAttribPointer(_yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squarVertices);
    glVertexAttribPointer(_yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordies);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (GLuint)outputTexture {
    return _yuvConversionFrameBuffer.texture;
}

#pragma mark - 

- (void)informTargetsNewFrame:(CMTime)time {
    for (id<GPUInput> target in _targets) {
        [target setInputSize:CGSizeMake(imageBufferWidth, imageBufferHeight) atIndex:_textureIndex];
        [target setInputFramebuffer:_yuvConversionFrameBuffer atIndex:_textureIndex];
        [target newFrameReadyAtTime:time atIndex:_textureIndex];
    }
}

- (void)addTarget:(id<GPUInput>)target {
    if (![_targets containsObject:target]) {
        [_targets addObject:target];
    }
}

- (void)removeAllTargets {
    [_targets removeAllObjects];
}

@end
