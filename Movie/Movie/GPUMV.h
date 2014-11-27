//
//  GPUMV.h
//  Movie
//
//  Created by lijian on 14/11/24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPUMV : NSObject

- (id)initWithMovies:(NSArray *)movies;
- (void)loadMV:(NSString *)path;

- (void)startMV;
- (void)didEndMV;
- (void)cancelMV;

@end
