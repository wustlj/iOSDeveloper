//
//  GPUReverseMovie.h
//  Movie
//
//  Created by lijian on 14/12/5.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUOutput.h"

@interface GPUReverseMovie : GPUOutput

- (id)initWithURL:(NSURL *)url;
- (void)startProcessing;

@end
