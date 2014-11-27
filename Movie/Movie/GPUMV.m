//
//  GPUMV.m
//  Movie
//
//  Created by lijian on 14/11/24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUMV.h"

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "MVParse.h"
#import "GPUMultiMovie.h"

#import "MovieComposition.h"

@interface GPUMV ()
{
    NSMutableArray *_baseResources;
    NSMutableArray *_maskResources;
    NSMutableDictionary *_baseAssets;
    NSMutableDictionary *_maskAssets;
    
    GPUMultiMovie *_baseMovie;
}

@property (nonatomic, retain) NSString *configPath;

@end

@implementation GPUMV

- (id)initWithMovies:(NSArray *)movies {
    self = [super init];
    if (self) {
        _maskAssets = [[NSMutableDictionary alloc] init];
        _maskResources = [[NSMutableArray alloc] init];
        _baseResources = [[NSMutableArray alloc] initWithArray:movies];
        _baseAssets = [[NSMutableDictionary alloc]initWithCapacity:[movies count]];
    }
    return self;
}

- (void)dealloc {
    [_baseResources release];
    [_baseAssets release];
    [_maskResources release];
    [_maskAssets release];
    [_configPath release];
    
    [super dealloc];
}

#pragma mark - Property

#pragma mark -

- (void)loadMV:(NSString *)path {
    self.configPath = path;
    
    [self parse];
}

- (void)startMV {
    [self load];
    
    [_baseMovie startProcessing];
}

- (void)didEndMV {
    
}

- (void)cancelMV {
    
}

#pragma mark - Parse

- (void)parse {
    [MVParse parse:self.configPath completionHandler:^(NSArray *arr) {
        NSLog(@"%@", arr);
        [_maskResources removeAllObjects];
        [_maskResources addObjectsFromArray:arr];
        
        [self loadMovieTrack];
    }];
}

#pragma mark - load and unload

- (void)load {
    if (!_baseMovie) {
        _baseMovie = [[GPUMultiMovie alloc] initWithVideos:_baseResources withAssets:_baseAssets];
    }
}

- (void)unload {
    
}

#pragma mark - Pre-Load Tracks

- (void)loadMovieTrack {
    dispatch_group_t group = dispatch_group_create();
    
    for (NSURL *url in _maskResources) {
        if ([[_maskAssets allKeys] containsObject:[url absoluteString]]) {
            continue;
        }
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:url options:inputOptions];
        
        [_maskAssets setObject:inputAsset forKey:[url absoluteString]];
        
        dispatch_group_enter(group);
        [inputAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (!tracksStatus == AVKeyValueStatusLoaded)
            {
                NSLog(@"<Warning>Load (%@) tracks failed", inputAsset);
            }
            dispatch_group_leave(group);
        }];
    }
    
    for (MovieComposition *c in _baseResources) {
        if ([[_baseAssets allKeys] containsObject:[c.videoURL absoluteString]]) {
            continue;
        }
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:c.videoURL options:inputOptions];
        
        [_baseAssets setObject:inputAsset forKey:[c.videoURL absoluteString]];
        
        dispatch_group_enter(group);
        [inputAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (!tracksStatus == AVKeyValueStatusLoaded)
            {
                NSLog(@"<Warning>Load (%@) tracks failed", inputAsset);
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        dispatch_release(group);
        [self didLoadTrackValueFinished];
    });
}

- (void)didLoadTrackValueFinished {
    NSLog(@"all loaded");
    
    [self startMV];
}

@end
