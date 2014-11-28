//
//  GPUMV.h
//  Movie
//
//  Created by lijian on 14/11/24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUHeader.h"

@interface GPUMV : NSObject

@property (nonatomic, assign) GPUView *glView;

- (id)initWithMovies:(NSArray *)movies;
- (void)loadMV:(NSString *)path;

- (void)startMV;
- (void)didEndMV;
- (void)cancelMV;

@end
