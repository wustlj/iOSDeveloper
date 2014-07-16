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
        
        [self commInit];
        
        [self setupYUVProgram];
        
        _textureCacheRef = [[GPUContext sharedImageProcessingContext] coreVideoTextureCache];
    }
    return self;
}

- (void)commInit {
    _keepLooping = YES;
}

- (void)dealloc {
    [_url release];
    [_asset release];
    [_assetReader release];
    [_videoTrackOutput release];
    
    [_yuvConversionProgram release];
    
    Block_release(_completionBlock);
    
    [self destroyYUVConversionFBO];
    
    [super dealloc];
}

#pragma mark - Movie

- (void)startProcessing {
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:self.url options:inputOptions];
    
    typeof(self) __block blockSelf = self;
    
    [inputAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
        if (!tracksStatus == AVKeyValueStatusLoaded)
        {
            return;
        }
        blockSelf.asset = inputAsset;
        [blockSelf processAsset];
        blockSelf = nil;
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
        [self processMovieFrame:movieFrame];
        CMSampleBufferInvalidate(bufferRef);
        CFRelease(bufferRef);
    } else {
        if (_assetReader.status == AVAssetReaderStatusCompleted) {
            [self endProcessing];
        }
    }
    return YES;
}

- (void)processMovieFrame:(CVPixelBufferRef)movieFrame {
    CVPixelBufferLockBaseAddress(movieFrame, 0);
    size_t width = CVPixelBufferGetWidth(movieFrame);
    size_t height = CVPixelBufferGetHeight(movieFrame);
    
    if (imageBufferHeight != height || imageBufferWidth != width) {
        imageBufferHeight = height;
        imageBufferWidth = width;
    }
    
    glActiveTexture(GL_TEXTURE4);
    CVOpenGLESTextureRef yPlaneTextureOut = NULL;
    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCacheRef, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &yPlaneTextureOut);
    _luminanceTexture = CVOpenGLESTextureGetName(yPlaneTextureOut);
    glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glActiveTexture(GL_TEXTURE5);
    CVOpenGLESTextureRef uvPlaneTextureOut = NULL;
    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCacheRef, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, width/2, height/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &uvPlaneTextureOut);
    _chrominanceTexture = CVOpenGLESTextureGetName(uvPlaneTextureOut);
    glBindTexture(GL_TEXTURE_2D, _chrominanceTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    [self convertYUVToRGBOutput];
    
    if (_completionBlock) {
        _completionBlock();
    }
    
    CFRelease(yPlaneTextureOut);
    CFRelease(uvPlaneTextureOut);
    
    CVPixelBufferUnlockBaseAddress(movieFrame, 0);
}

- (void)endProcessing {
    NSLog(@"end processing");
}

#pragma mark - GPU

- (void)setupYUVProgram {
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
}

- (void)convertYUVToRGBOutput {
    [GPUContext setActiveShaderProgram:_yuvConversionProgram];
    
    if (!_yuvConversionFrameBuffer) {
        [self destroyYUVConversionFBO];
        [self createYUVConversionFBO];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, _yuvConversionFrameBuffer);
    glViewport(0, 0, imageBufferWidth, imageBufferHeight);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BITS);
    
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

- (void)createYUVConversionFBO {
    glGenFramebuffers(1, &_yuvConversionFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _yuvConversionFrameBuffer);
    
    [self initializeOutputTexture];
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)destroyYUVConversionFBO {
    if (_yuvConversionFrameBuffer) {
        glDeleteFramebuffers(1, &_yuvConversionFrameBuffer);
        _yuvConversionFrameBuffer = 0;
    }
    
    if (_renderTarget) {
        CFRelease(_renderTarget);
        _renderTarget = NULL;
    }
    
    if (_renderTexture) {
        CFRelease(_renderTexture);
        _renderTexture = NULL;
    }
    
    _outputTexture = 0;
}

- (void)initializeOutputTexture {
    if (!_outputTexture) {
        [GPUContext useImageProcessingContext];
        
        CFDictionaryRef empty; // empty value for attr value.
        CFMutableDictionaryRef attrs;
        empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
        attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
        
        CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, imageBufferWidth, imageBufferHeight, kCVPixelFormatType_32BGRA, attrs, &_renderTarget);
        if (err)
        {
            NSLog(@"FBO size: %d, %d", imageBufferWidth, imageBufferHeight);
            NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
        }
        
        err = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, _textureCacheRef, _renderTarget,
                                                            NULL, // texture attributes
                                                            GL_TEXTURE_2D,
                                                            GL_RGBA, // opengl format
                                                            imageBufferWidth,
                                                            imageBufferHeight,
                                                            GL_BGRA, // native iOS format
                                                            GL_UNSIGNED_BYTE,
                                                            0,
                                                            &_renderTexture);
        if (err)
        {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }
        
        CFRelease(attrs);
        CFRelease(empty);
        
        glBindTexture(CVOpenGLESTextureGetTarget(_renderTexture), CVOpenGLESTextureGetName(_renderTexture));
        _outputTexture = CVOpenGLESTextureGetName(_renderTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(_renderTexture), 0);
    }
}

@end
