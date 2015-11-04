//
//  TMutableArray.m
//  block
//
//  Created by lijian on 15/11/4.
//  Copyright © 2015年 youku. All rights reserved.
//

#import "TMutableArray.h"

@implementation TObject

- (id)init {
    self = [super init];
    if (self) {
        _array = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"TObject dealloc");
}

@end
