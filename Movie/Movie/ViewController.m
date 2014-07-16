//
//  ViewController.m
//  Movie
//
//  Created by lijian on 14-7-2.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "GPUView.h"
#import "GPUContext.h"

#import "GPUMovie.h"

const GLfloat kColorConversion601FullRange[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

NSString *const kGPUImageVertexShaderString = SHADER_STRING
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

NSString *const kGPUImageYUVVideoRangeConversionForLAFragmentShaderString = SHADER_STRING
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

@interface ViewController ()
{
    int imageBufferWidth, imageBufferHeight;
    
    CVOpenGLESTextureCacheRef textureCacheRef;

    AVAssetReader *_assetReader;
    AVAssetReaderTrackOutput *_videoTrackOutput;
    GPUProgram *yuvConversionProgram;
    GLuint yuvConversionPositionAttribute, yuvConversionTextureCoordinateAttribute;
    GLint yuvConversionLuminanceTextureUniform, yuvConversionChrominanceTextureUniform;
    GLint yuvConversionMatrixUniform;
    GLuint yuvConversionFrameBuffer;
    GLuint luminanceTexture;
    GLuint chrominanceTexture;
    CVPixelBufferRef renderTarget;
    GLuint _texture;
    CVOpenGLESTextureRef renderTexture;
    GPUView *_glView;
    
    AVAssetReader *_assetReader2;
    AVAssetReaderTrackOutput *_videoTrackOutput2;
    GPUProgram *yuvConversionProgram2;
    GLuint yuvConversionPositionAttribute2, yuvConversionTextureCoordinateAttribute2;
    GLint yuvConversionLuminanceTextureUniform2, yuvConversionChrominanceTextureUniform2;
    GLint yuvConversionMatrixUniform2;
    GLuint yuvConversionFrameBuffer2;
    GLuint luminanceTexture2;
    GLuint chrominanceTexture2;
    CVPixelBufferRef renderTarget2;
    GLuint _texture2;
    CVOpenGLESTextureRef renderTexture2;
    GPUView *_glView2;
    
    GPUMovie *_movie1;
    GPUMovie *_movie2;
}
@end

@implementation ViewController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [yuvConversionProgram release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self initGPU];
    
    _glView = [[GPUView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [self.view addSubview:_glView];
    [_glView release];
    
    _glView2 = [[GPUView alloc] initWithFrame:CGRectMake(120, 320, 200, 200)];
    [self.view addSubview:_glView2];
    [_glView2 release];
    
    imageBufferWidth = 1920;
    imageBufferHeight = 1080;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 400, 100, 50)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"Begin" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startGPUMovie) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setFrame:CGRectMake(0, 500, 100, 50)];
    [btn2 setBackgroundColor:[UIColor redColor]];
    [btn2 setTitle:@"Begin" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(startRead2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

- (void)initGPU {
    [self setupTextureCache];
}

- (void)setupTextureCache {
    CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [[GPUContext sharedImageProcessingContext] context], NULL, &textureCacheRef);
}

#pragma mark - YUV Conversion

- (void)setupYUVProgram {
    [GPUContext useImageProcessingContext];
    
    yuvConversionProgram = [[[GPUContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageYUVVideoRangeConversionForLAFragmentShaderString] retain];
    
    [yuvConversionProgram addAttribute:@"position"];
    [yuvConversionProgram addAttribute:@"inputTextureCoordinate"];
    
    if (![yuvConversionProgram link]) {
        NSLog(@"yuvConversionProgram link fail");
    };
    
    yuvConversionPositionAttribute = [yuvConversionProgram attributeIndex:@"position"];
    yuvConversionTextureCoordinateAttribute = [yuvConversionProgram attributeIndex:@"inputTextureCoordinate"];
    yuvConversionLuminanceTextureUniform = [yuvConversionProgram uniformIndex:@"luminanceTexture"];
    yuvConversionChrominanceTextureUniform = [yuvConversionProgram uniformIndex:@"chrominanceTexture"];
    yuvConversionMatrixUniform = [yuvConversionProgram uniformIndex:@"colorConversionMatrix"];
    
    [GPUContext setActiveShaderProgram:yuvConversionProgram];
    
    glEnableVertexAttribArray(yuvConversionPositionAttribute);
    glEnableVertexAttribArray(yuvConversionTextureCoordinateAttribute);
}

- (void)convertYUVToRGBOutput {
    [GPUContext setActiveShaderProgram:yuvConversionProgram];
    
    glBindFramebuffer(GL_FRAMEBUFFER, yuvConversionFrameBuffer);
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
    glBindTexture(GL_TEXTURE_2D, luminanceTexture);
    glUniform1i(yuvConversionLuminanceTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
    glUniform1i(yuvConversionChrominanceTextureUniform, 5);
    
    glUniformMatrix3fv(yuvConversionMatrixUniform, 1, GL_FALSE, kColorConversion601FullRange);
    
    glVertexAttribPointer(yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squarVertices);
    glVertexAttribPointer(yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordies);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)createYUVConversionFBO {
    glGenFramebuffers(1, &yuvConversionFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, yuvConversionFrameBuffer);
    
    [self initializeOutputTexture];
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)destroyYUVConversionFBO {
    if (yuvConversionFrameBuffer) {
        glDeleteFramebuffers(1, &yuvConversionFrameBuffer);
        yuvConversionFrameBuffer = 0;
    }
    
    if (renderTarget) {
        CFRelease(renderTarget);
        renderTarget = NULL;
    }
    
    if (renderTexture) {
        CFRelease(renderTexture);
        renderTexture = NULL;
    }
    
    _texture = 0;
}

- (void)initializeOutputTexture {
    if (!_texture) {
        [GPUContext useImageProcessingContext];
        
        CFDictionaryRef empty; // empty value for attr value.
        CFMutableDictionaryRef attrs;
        empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
        attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
        
        CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, imageBufferWidth, imageBufferHeight, kCVPixelFormatType_32BGRA, attrs, &renderTarget);
        if (err)
        {
            NSLog(@"FBO size: %d, %d", imageBufferWidth, imageBufferHeight);
            NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
        }
        
        err = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, textureCacheRef, renderTarget,
                                                            NULL, // texture attributes
                                                            GL_TEXTURE_2D,
                                                            GL_RGBA, // opengl format
                                                            imageBufferWidth,
                                                            imageBufferHeight,
                                                            GL_BGRA, // native iOS format
                                                            GL_UNSIGNED_BYTE,
                                                            0,
                                                            &renderTexture);
        if (err)
        {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }
        
        CFRelease(attrs);
        CFRelease(empty);
        
        glBindTexture(CVOpenGLESTextureGetTarget(renderTexture), CVOpenGLESTextureGetName(renderTexture));
        _texture = CVOpenGLESTextureGetName(renderTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(renderTexture), 0);
    }
}

- (void)setupYUVProgram2 {
    [GPUContext useImageProcessingContext];
    
    yuvConversionProgram2 = [[[GPUContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageYUVVideoRangeConversionForLAFragmentShaderString] retain];
    
    [yuvConversionProgram2 addAttribute:@"position"];
    [yuvConversionProgram2 addAttribute:@"inputTextureCoordinate"];
    
    if (![yuvConversionProgram2 link]) {
        NSLog(@"yuvConversionProgram link fail");
    };
    
    yuvConversionPositionAttribute2 = [yuvConversionProgram2 attributeIndex:@"position"];
    yuvConversionTextureCoordinateAttribute2 = [yuvConversionProgram2 attributeIndex:@"inputTextureCoordinate"];
    yuvConversionLuminanceTextureUniform2 = [yuvConversionProgram2 uniformIndex:@"luminanceTexture"];
    yuvConversionChrominanceTextureUniform2 = [yuvConversionProgram2 uniformIndex:@"chrominanceTexture"];
    yuvConversionMatrixUniform2 = [yuvConversionProgram2 uniformIndex:@"colorConversionMatrix"];
    
    [GPUContext setActiveShaderProgram:yuvConversionProgram2];
    
    glEnableVertexAttribArray(yuvConversionPositionAttribute2);
    glEnableVertexAttribArray(yuvConversionTextureCoordinateAttribute2);
}

- (void)convertYUVToRGBOutput2 {
    [GPUContext setActiveShaderProgram:yuvConversionProgram2];
    
    glBindFramebuffer(GL_FRAMEBUFFER, yuvConversionFrameBuffer2);
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
    glBindTexture(GL_TEXTURE_2D, luminanceTexture2);
    glUniform1i(yuvConversionLuminanceTextureUniform2, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, chrominanceTexture2);
    glUniform1i(yuvConversionChrominanceTextureUniform2, 5);
    
    glUniformMatrix3fv(yuvConversionMatrixUniform2, 1, GL_FALSE, kColorConversion601FullRange);
    
    glVertexAttribPointer(yuvConversionPositionAttribute2, 2, GL_FLOAT, 0, 0, squarVertices);
    glVertexAttribPointer(yuvConversionTextureCoordinateAttribute2, 2, GL_FLOAT, 0, 0, textureCoordies);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)createYUVConversionFBO2 {
    glGenFramebuffers(1, &yuvConversionFrameBuffer2);
    glBindFramebuffer(GL_FRAMEBUFFER, yuvConversionFrameBuffer2);
    
    [self initializeOutputTexture2];
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)destroyYUVConversionFBO2 {
    if (yuvConversionFrameBuffer2) {
        glDeleteFramebuffers(1, &yuvConversionFrameBuffer2);
        yuvConversionFrameBuffer2 = 0;
    }
    
    if (renderTarget2) {
        CFRelease(renderTarget2);
        renderTarget2 = NULL;
    }
    
    if (renderTexture2) {
        CFRelease(renderTexture2);
        renderTexture2 = NULL;
    }
    
    _texture2 = 0;
}

- (void)initializeOutputTexture2 {
    if (!_texture2) {
        [GPUContext useImageProcessingContext];
        
        CFDictionaryRef empty; // empty value for attr value.
        CFMutableDictionaryRef attrs;
        empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
        attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
        
        CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, imageBufferWidth, imageBufferHeight, kCVPixelFormatType_32BGRA, attrs, &renderTarget2);
        if (err)
        {
            NSLog(@"FBO size: %d, %d", imageBufferWidth, imageBufferHeight);
            NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
        }
        
        err = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, textureCacheRef, renderTarget2,
                                                            NULL, // texture attributes
                                                            GL_TEXTURE_2D,
                                                            GL_RGBA, // opengl format
                                                            imageBufferWidth,
                                                            imageBufferHeight,
                                                            GL_BGRA, // native iOS format
                                                            GL_UNSIGNED_BYTE,
                                                            0,
                                                            &renderTexture2);
        if (err)
        {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }
        
        CFRelease(attrs);
        CFRelease(empty);
        
        glBindTexture(CVOpenGLESTextureGetTarget(renderTexture2), CVOpenGLESTextureGetName(renderTexture2));
        _texture2 = CVOpenGLESTextureGetName(renderTexture2);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(renderTexture2), 0);
    }
}

#pragma mark - Action

- (void)startGPUMovie {
    if (!_movie1) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480" ofType:@"mp4"]];
        _movie1 = [[GPUMovie alloc] initWithURL:videoURL];
    }
    
    if (!_movie2) {
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"PTstar" ofType:@"mp4"]];
        _movie2 = [[GPUMovie alloc] initWithURL:videoURL];
        _movie2.keepLooping = NO;
        [_movie2 startProcessing];
    }
    
    __block typeof(self) oneself = self;
    
    _movie1.completionBlock = ^ {
        [oneself reloadView1];
    };
    
    _movie2.completionBlock = ^ {
        [oneself reloadView2];
    };
    
    [_movie1 startProcessing];
}

- (void)reloadView1 {
    [_movie2 readNextVideoFrame];
    
    _glView.outputTexture = _movie1.outputTexture;
    [_glView draw];
}

- (void)reloadView2 {
    _glView.outputTexture2 = _movie2.outputTexture;
}

- (void)startAtTheSameTime {
    [self startRead];
    [self startRead2];
}

- (void)startRead {
    if (!yuvConversionProgram) {
        [self setupYUVProgram];
        
        [self destroyYUVConversionFBO];
        [self createYUVConversionFBO];
    }
    
    if (!_assetReader) {
        NSError *error = nil;
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera480" ofType:@"mp4"]];
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        _assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        if (error) {
            NSLog(@"%@", [error description]);
            return;
        }
        
        NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *track = [videoTracks objectAtIndex:0];
        NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        _videoTrackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:outputSettings];
        
        if ([_assetReader canAddOutput:_videoTrackOutput]) {
            [_assetReader addOutput:_videoTrackOutput];
        }
        
        if ([_assetReader startReading]) {
            NSLog(@"%ld", (long)_assetReader.status);
        }
    }
    
    if (_assetReader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef bufferRef = [_videoTrackOutput copyNextSampleBuffer];
        if (bufferRef && CMSampleBufferIsValid(bufferRef)) {
            CMTime movieTime =  CMSampleBufferGetPresentationTimeStamp(bufferRef);
            CVImageBufferRef movieFrame = CMSampleBufferGetImageBuffer(bufferRef);
            CMTimeShow(movieTime);
            
//                UInt32 type = CVPixelBufferGetPixelFormatType(movieFrame);
//                if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
//                    NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarFullRange done");
//                } ;
//
//                if (type == kCVPixelFormatType_420YpCbCr8PlanarFullRange) {
//                    NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarFullRange done");
//                }
//
//                NSLog(@"Plane Count : %zu", CVPixelBufferGetPlaneCount(movieFrame));
//
//                NSLog(@"Plane 0 Width:%zu", CVPixelBufferGetWidthOfPlane(movieFrame, 0));
//                NSLog(@"Plane 1 Width:%zu", CVPixelBufferGetWidthOfPlane(movieFrame, 1));
//                NSLog(@"Plane 0 Height:%zu", CVPixelBufferGetHeightOfPlane(movieFrame, 0));
//                NSLog(@"Plane 1 Height:%zu", CVPixelBufferGetHeightOfPlane(movieFrame, 1));
            
            CVPixelBufferLockBaseAddress(movieFrame, 0);
            size_t width = CVPixelBufferGetWidth(movieFrame);
            size_t height = CVPixelBufferGetHeight(movieFrame);
            
            glActiveTexture(GL_TEXTURE4);
            CVOpenGLESTextureRef yPlaneTextureOut = NULL;
            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCacheRef, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &yPlaneTextureOut);
            luminanceTexture = CVOpenGLESTextureGetName(yPlaneTextureOut);
            glBindTexture(GL_TEXTURE_2D, luminanceTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glActiveTexture(GL_TEXTURE5);
            CVOpenGLESTextureRef uvPlaneTextureOut = NULL;
            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCacheRef, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, width/2, height/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &uvPlaneTextureOut);
            chrominanceTexture = CVOpenGLESTextureGetName(uvPlaneTextureOut);
            glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            [self convertYUVToRGBOutput];
            
            _glView.outputTexture = _texture;
            [_glView draw];
            
            CFRelease(yPlaneTextureOut);
            CFRelease(uvPlaneTextureOut);
            
            CVPixelBufferUnlockBaseAddress(movieFrame, 0);
            
            CMSampleBufferInvalidate(bufferRef);
            CFRelease(bufferRef);
        } else {
            NSLog(@"%d", _assetReader.status);
            [_assetReader cancelReading];
            NSLog(@"%d", _assetReader.status);
        }
    }
}

- (void)startRead2 {
    if (!yuvConversionProgram2) {
        [self setupYUVProgram2];
        
        [self destroyYUVConversionFBO2];
        [self createYUVConversionFBO2];
    }
    
    if (!_assetReader2) {
        NSError *error = nil;
        NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"PTstar" ofType:@"mp4"]];
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        _assetReader2 = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        if (error) {
            NSLog(@"%@", [error description]);
            return;
        }
        
        NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *track = [videoTracks objectAtIndex:0];
        NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        _videoTrackOutput2 = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:outputSettings];
        
        if ([_assetReader2 canAddOutput:_videoTrackOutput2]) {
            [_assetReader2 addOutput:_videoTrackOutput2];
        }
        
        if ([_assetReader2 startReading]) {
            NSLog(@"%ld", (long)_assetReader2.status);
        }
    }
    
    if (_assetReader2.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef bufferRef = [_videoTrackOutput2 copyNextSampleBuffer];
        if (bufferRef && CMSampleBufferIsValid(bufferRef)) {
            CMTime movieTime =  CMSampleBufferGetPresentationTimeStamp(bufferRef);
            CVImageBufferRef movieFrame = CMSampleBufferGetImageBuffer(bufferRef);
            CMTimeShow(movieTime);
            
            UInt32 type = CVPixelBufferGetPixelFormatType(movieFrame);
            if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarFullRange done");
            } ;
            
            if (type == kCVPixelFormatType_420YpCbCr8PlanarFullRange) {
                NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarFullRange done");
            }
            
            NSLog(@"Plane Count : %zu", CVPixelBufferGetPlaneCount(movieFrame));
            
            NSLog(@"Plane 0 Width:%zu", CVPixelBufferGetWidthOfPlane(movieFrame, 0));
            NSLog(@"Plane 1 Width:%zu", CVPixelBufferGetWidthOfPlane(movieFrame, 1));
            NSLog(@"Plane 0 Height:%zu", CVPixelBufferGetHeightOfPlane(movieFrame, 0));
            NSLog(@"Plane 1 Height:%zu", CVPixelBufferGetHeightOfPlane(movieFrame, 1));
            
            CVPixelBufferLockBaseAddress(movieFrame, 0);
            void *baseAddress = CVPixelBufferGetBaseAddress(movieFrame);
            size_t width = CVPixelBufferGetWidth(movieFrame);
            size_t height = CVPixelBufferGetHeight(movieFrame);
            size_t bufferSize = CVPixelBufferGetDataSize(movieFrame);
            size_t bytesPerRow = CVPixelBufferGetBytesPerRow(movieFrame);//CVPixelBufferGetBytesPerRowOfPlane(movieFrame, 0);
            
            glActiveTexture(GL_TEXTURE4);
            CVOpenGLESTextureRef yPlaneTextureOut = NULL;
            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCacheRef, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &yPlaneTextureOut);
            luminanceTexture2 = CVOpenGLESTextureGetName(yPlaneTextureOut);
            glBindTexture(GL_TEXTURE_2D, luminanceTexture2);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glActiveTexture(GL_TEXTURE5);
            CVOpenGLESTextureRef uvPlaneTextureOut = NULL;
            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCacheRef, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, width/2, height/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &uvPlaneTextureOut);
            chrominanceTexture2 = CVOpenGLESTextureGetName(uvPlaneTextureOut);
            glBindTexture(GL_TEXTURE_2D, chrominanceTexture2);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            [self convertYUVToRGBOutput2];
            
//            _glView2.outputTexture = _texture2;
//            [_glView2 draw];
            _glView.outputTexture2 = _texture2;
            
            CFRelease(yPlaneTextureOut);
            CFRelease(uvPlaneTextureOut);
            
            CVPixelBufferUnlockBaseAddress(movieFrame, 0);
            
            CMSampleBufferInvalidate(bufferRef);
            CFRelease(bufferRef);
        } else {
            NSLog(@"%d", _assetReader2.status);
            [_assetReader2 cancelReading];
            NSLog(@"%d", _assetReader2.status);
        }
    }
}

- (void)export2:(AVAssetReaderTrackOutput *)videoTrackOutput {
    while (_assetReader2.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef bufferRef = [videoTrackOutput copyNextSampleBuffer];
        if (bufferRef && CMSampleBufferIsValid(bufferRef)) {
            CMTime movieTime =  CMSampleBufferGetPresentationTimeStamp(bufferRef);
            CVImageBufferRef movieFrame = CMSampleBufferGetImageBuffer(bufferRef);
            CMTimeShow(movieTime);
            
            UInt32 type = CVPixelBufferGetPixelFormatType(movieFrame);
            if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarFullRange done");
            } ;
            
            if (type == kCVPixelFormatType_420YpCbCr8PlanarFullRange) {
                NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarFullRange done");
            }
            
            NSLog(@"Plane Count : %zu", CVPixelBufferGetPlaneCount(movieFrame));
            
            NSLog(@"Plane 0 Width:%zu", CVPixelBufferGetWidthOfPlane(movieFrame, 0));
            NSLog(@"Plane 1 Width:%zu", CVPixelBufferGetWidthOfPlane(movieFrame, 1));
            NSLog(@"Plane 0 Height:%zu", CVPixelBufferGetHeightOfPlane(movieFrame, 0));
            NSLog(@"Plane 1 Height:%zu", CVPixelBufferGetHeightOfPlane(movieFrame, 1));
            
            CVPixelBufferLockBaseAddress(movieFrame, 0);
            void *baseAddress = CVPixelBufferGetBaseAddress(movieFrame);
            size_t width = CVPixelBufferGetWidth(movieFrame);
            size_t height = CVPixelBufferGetHeight(movieFrame);
            size_t bufferSize = CVPixelBufferGetDataSize(movieFrame);
            size_t bytesPerRow = CVPixelBufferGetBytesPerRow(movieFrame);//CVPixelBufferGetBytesPerRowOfPlane(movieFrame, 0);
            
            glActiveTexture(GL_TEXTURE4);
            CVOpenGLESTextureRef yPlaneTextureOut = NULL;
            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCacheRef, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &yPlaneTextureOut);
            luminanceTexture2 = CVOpenGLESTextureGetName(yPlaneTextureOut);
            glBindTexture(GL_TEXTURE_2D, luminanceTexture2);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glActiveTexture(GL_TEXTURE5);
            CVOpenGLESTextureRef uvPlaneTextureOut = NULL;
            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCacheRef, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, width/2, height/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &uvPlaneTextureOut);
            chrominanceTexture2 = CVOpenGLESTextureGetName(uvPlaneTextureOut);
            glBindTexture(GL_TEXTURE_2D, chrominanceTexture2);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            [self convertYUVToRGBOutput2];
            
            _glView2.outputTexture = _texture2;
            [_glView2 draw];
            
            CFRelease(yPlaneTextureOut);
            CFRelease(uvPlaneTextureOut);
            
            CVPixelBufferUnlockBaseAddress(movieFrame, 0);
            
            CMSampleBufferInvalidate(bufferRef);
            CFRelease(bufferRef);
        } else {
            NSLog(@"%d", _assetReader2.status);
            [_assetReader2 cancelReading];
            NSLog(@"%d", _assetReader2.status);
        }
    }
}

@end
