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

@interface GPUMV ()
{
    NSMutableArray *_baseMovies;
    NSMutableArray *_maskMovies;
    NSMutableDictionary *_baseAssets;
    NSMutableDictionary *_maskAssets;
}

@property (nonatomic, retain) NSString *configPath;

@end

@implementation GPUMV

- (id)initWithMovies:(NSArray *)movies {
    self = [super init];
    if (self) {
        _maskAssets = [[NSMutableDictionary alloc] init];
        _maskMovies = [[NSMutableArray alloc] init];
        _baseMovies = [[NSMutableArray alloc] initWithArray:movies];
        _baseAssets = [[NSMutableDictionary alloc]initWithCapacity:[movies count]];
    }
    return self;
}

- (void)dealloc {
    [_baseMovies release];
    [_baseAssets release];
    [_maskMovies release];
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
    
}

- (void)didEndMV {
    
}

- (void)cancelMV {
    
}

#pragma mark - Parse

- (void)parse {
    [MVParse parse:self.configPath completionHandler:^(NSArray *arr) {
        NSLog(@"%@", arr);
        [_maskMovies removeAllObjects];
        [_maskMovies addObjectsFromArray:arr];
        
        [self loadMovieTrack];
    }];
}

#pragma mark - load and unload

- (void)load {
    
    
}

- (void)unload {
    
}

#pragma mark - Pre-Load Tracks

- (void)loadMovieTrack {
    dispatch_group_t group = dispatch_group_create();
    
    for (NSURL *url in _maskMovies) {
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
    
    for (NSURL *url in _baseMovies) {
        if ([[_baseAssets allKeys] containsObject:[url absoluteString]]) {
            continue;
        }
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:url options:inputOptions];
        
        [_baseAssets setObject:inputAsset forKey:[url absoluteString]];
        
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
}

@end
