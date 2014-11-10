//
//  GPUMovieWriter.m
//  Movie
//
//  Created by lijian on 14-10-20.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUMovieWriter.h"

NSString *const kMovieVertexShaderString = SHADER_STRING
(
 attribute vec4 vPosition;
 attribute vec2 textureCoord;
 
 varying vec2 textureCoordOut;
 
 void main()
 {
     gl_Position = vPosition;
     textureCoordOut = textureCoord;
 }
 );

NSString *const kMovieFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordOut;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordOut);
 }
 );

@interface GPUMovieWriter ()
{
    GLuint _frameBuffer;
    CVPixelBufferRef _pixelBuffer;
    CVOpenGLESTextureRef _renderTexture;
    GPUFramebuffer *_inputFrameBuffer;
    
    CMTime startTime;
}
@property (nonatomic, strong) NSURL *movieURL;
@property (nonatomic) CGSize movieSize;

@end

@implementation GPUMovieWriter

- (id)initWithURL:(NSURL *)movieURL size:(CGSize)movieSize
{
    return [self initWithURL:movieURL size:movieSize fileType:AVFileTypeQuickTimeMovie];
}

- (id)initWithURL:(NSURL *)movieURL size:(CGSize)movieSize fileType:(NSString *)outputFileType
{
    self = [super init];
    if (self) {
        self.movieURL = movieURL;
        self.movieSize = movieSize;
        
        startTime = kCMTimeInvalid;
        
        [GPUContext useImageProcessingContext];
        _program = [[GPUProgram alloc] initWithVertexShaderString:kMovieVertexShaderString fragmentShaderString:kMovieFragmentShaderString];
        
        [_program addAttribute:@"vPosition"];
        [_program addAttribute:@"textureCoord"];
        
        [_program link];
        
        [GPUContext setActiveShaderProgram:_program];

//        runSynchronouslyOnVideoProcessingQueue(^{
            _positionSlot = [_program attributeSlot:@"vPosition"];
            _textureSlot = [_program attributeSlot:@"textureCoord"];
            _samplerSlot = [_program uniformIndex:@"inputImageTexture"];
//        });
        
        [self initWriter];
    }
    return self;
}

- (void)dealloc
{
    Block_release(_finishBlock);
    [_movieURL release];
    [_assetWriter release];
    [_audioInput release];
    [_videoInput release];
    [_assetWriterInputPixelBufferAdaptor release];
    
    [self destroyFBO];
    
    [super dealloc];
}

#pragma mark - Writer

- (void)initWriter
{
    NSError *error = nil;
    _assetWriter = [[AVAssetWriter assetWriterWithURL:_movieURL fileType:AVFileTypeQuickTimeMovie error:&error] retain];
    if (error) {
        NSLog(@"Error:%@", [error description]);
    }
    
    _assetWriter.movieFragmentInterval = CMTimeMakeWithSeconds(1.0, 1000);
    
    AVAudioSession *sharedAudioSession = [AVAudioSession sharedInstance];
    double preferredHardwareSampleRate;
    
    if ([sharedAudioSession respondsToSelector:@selector(sampleRate)])
    {
        preferredHardwareSampleRate = [sharedAudioSession sampleRate];
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        preferredHardwareSampleRate = [[AVAudioSession sharedInstance] currentHardwareSampleRate];
#pragma clang diagnostic pop
    }
    
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;

    NSDictionary *audioSettings = @{AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
                                    AVSampleRateKey: [NSNumber numberWithDouble:preferredHardwareSampleRate],
                                    AVNumberOfChannelsKey: [NSNumber numberWithInt:1],
                                    AVChannelLayoutKey: [NSData dataWithBytes:&acl length:sizeof(acl)],
                                    AVEncoderBitRateKey: [ NSNumber numberWithInt:64000]
                                    };
#warning TODO audioSettings is not used
    _audioInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil] retain];
//    [_assetWriter addInput:_audioInput];
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: [NSNumber numberWithInt:_movieSize.width],
                                    AVVideoHeightKey: [NSNumber numberWithInt:_movieSize.height]
                                    };
    
    _videoInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings] retain];
    _videoInput.expectsMediaDataInRealTime = YES;
    
    // kCVPixelBufferPixelFormatTypeKey must kCVPixelFormatType_32BGRA, or CVPixelBufferPoolCreatePixelBuffer will fail with kCVReturnInvalidPixelFormat
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                                           [NSNumber numberWithInt:_movieSize.width], kCVPixelBufferWidthKey,
                                                           [NSNumber numberWithInt:_movieSize.height], kCVPixelBufferHeightKey,
                                                           nil];
    _assetWriterInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary] retain];
    
    [_assetWriter addInput:_videoInput];
}

- (void)startWriting
{
    [_assetWriter startWriting];
}

- (void)cancelWriting
{
    [_assetWriter cancelWriting];
}

#pragma mark - GPUInput

- (void)newAudioBuffer:(CMSampleBufferRef)bufferRef
{
    void (^write)() = ^{
        if (!_audioInput.readyForMoreMediaData) {
            NSLog(@"drop audio");
        } else if (![_audioInput appendSampleBuffer:bufferRef]) {
            NSLog(@"append audio failed");
        }
    };
    
    write();
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    if (CMTIME_IS_INVALID(startTime)) {
//        if (_assetWriter.status != AVAssetWriterStatusWriting) {
//            [_assetWriter startWriting];
//        }
        [_assetWriter startSessionAtSourceTime:frameTime];
        startTime = frameTime;
    }
    
    [self draw];
    
    CVPixelBufferRef pixel_buffer = NULL;
    pixel_buffer = _pixelBuffer;
    CVPixelBufferLockBaseAddress(pixel_buffer, 0);
    
    void(^write)() = ^{
//        while (!_videoInput.readyForMoreMediaData) {
//            NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
//            NSLog(@"video waiting...");
//            [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
//        }
        
        if (!_videoInput.readyForMoreMediaData) {
            NSLog(@"drop frame at time:%@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, frameTime)));
        } else if(![_assetWriterInputPixelBufferAdaptor appendPixelBuffer:pixel_buffer withPresentationTime:frameTime]) {
            NSLog(@"append video failed at time:%@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, frameTime)));
            if (_assetWriter.status == AVAssetWriterStatusFailed) {
                NSLog(@"%@", _assetWriter.error);
            }
        }
        CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);
    };
    
    write();
}

- (void)setInputFramebuffer:(GPUFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    _inputFrameBuffer = newInputFramebuffer;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    _movieSize = newSize;  
}

- (NSInteger)nextAvailableTextureIndex {
    return 0;
}

- (void)endProcessing
{
    [_videoInput markAsFinished];
//    [_audioInput markAsFinished];
    
    [_assetWriter finishWritingWithCompletionHandler:^{
        NSLog(@"write finished");
        
        if (_finishBlock) {
            _finishBlock();
        }
    }];
}

#pragma mark - Draw

- (void)draw {
    [GPUContext useImageProcessingContext];
    
    [self setFilterFBO];

    [GPUContext setActiveShaderProgram:_program];
    
    const GLfloat squarVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    const GLfloat *textureCoordies = [self textureCoordiesWithOrientation:kRotateNone];
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
    glVertexAttribPointer(_positionSlot, 2, GL_FLOAT, GL_FALSE, 0, squarVertices);
    glEnableVertexAttribArray(_positionSlot);
    
    glVertexAttribPointer(_textureSlot, 2, GL_FLOAT, GL_FALSE, 0, textureCoordies);
    glEnableVertexAttribArray(_textureSlot);
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, [_inputFrameBuffer texture]);
    glUniform1i(_samplerSlot, 6);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glFinish();
}

- (const GLfloat *)textureCoordiesWithOrientation:(WriterOrientation)orientation
{
    static const GLfloat noRotationTextureCoordies[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat rotationLeftTextureCoordies[] = {
        0.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    switch (orientation) {
        case kRotateNone: return noRotationTextureCoordies;
        case kRotateLeft: return rotationLeftTextureCoordies;
#warning TODO:Other Rotate Orientation
    }
    return noRotationTextureCoordies;
}

- (CGAffineTransform)transform {
    return _videoInput.transform;
}

- (void)setTransform:(CGAffineTransform)transform {
    _videoInput.transform = transform;
}

#pragma mark - FBO

- (void)setFilterFBO
{
    if (!_frameBuffer) {
        [self createFBO];
    }
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, _movieSize.width, _movieSize.height);
}

- (void)createFBO
{
    glActiveTexture(GL_TEXTURE1);
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, [_assetWriterInputPixelBufferAdaptor pixelBufferPool], &_pixelBuffer);
    CVBufferSetAttachment(_pixelBuffer, kCVImageBufferColorPrimariesKey, kCVImageBufferColorPrimaries_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
    CVBufferSetAttachment(_pixelBuffer, kCVImageBufferYCbCrMatrixKey, kCVImageBufferYCbCrMatrix_ITU_R_601_4, kCVAttachmentMode_ShouldPropagate);
    CVBufferSetAttachment(_pixelBuffer, kCVImageBufferTransferFunctionKey, kCVImageBufferTransferFunction_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
    
    CVOpenGLESTextureCacheRef textureCacheRef = [[GPUContext sharedImageProcessingContext] coreVideoTextureCache];

    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCacheRef, _pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, (int)_movieSize.width, (int)_movieSize.height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &_renderTexture);
    glBindTexture(CVOpenGLESTextureGetTarget(_renderTexture), CVOpenGLESTextureGetName(_renderTexture));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(_renderTexture), 0);

    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
}

- (void)destroyFBO
{
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_pixelBuffer) {
        CVPixelBufferRelease(_pixelBuffer);
    }
    
    if (_renderTexture) {
        CFRelease(_renderTexture);
    }
}

@end
