//
//  GPUMultiMovie.h
//  Movie
//
//  Created by lijian on 14/11/13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "GPUOutput.h"

@interface GPUMultiMovie : GPUOutput

- (id)initWithVideos:(NSArray *)videos;
- (id)initWithVideos:(NSArray *)videos withAssets:(NSMutableDictionary *)assets;

- (void)load;
- (void)startProcessing;
- (void)cancelProcessing;

@end