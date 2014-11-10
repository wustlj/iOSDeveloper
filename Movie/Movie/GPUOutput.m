//
//  GPUOutput.m
//  Movie
//
//  Created by lijian on 14/11/10.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "GPUOutput.h"

@implementation GPUOutput

- (id)init {
    self = [super init];
    if (self) {
        _targets = [[NSMutableArray alloc] init];
        _targetIndexs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self removeAllTargets];
    
    [_targets release];
    [_targetIndexs release];
    
    [super dealloc];
}

- (void)addTarget:(id<GPUInput>)target {
    if (![_targets containsObject:target]) {
        NSInteger index = [target nextAvailableTextureIndex];
        [_targets addObject:target];
        [_targetIndexs addObject:[NSNumber numberWithInteger:index]];
    }
}

- (void)removeTarget:(id<GPUInput>)target {
    if ([_targets containsObject:target]) {
        NSInteger indexOfObject = [_targets indexOfObject:target];
        NSNumber *targetIndex = [_targetIndexs objectAtIndex:indexOfObject];
        
        [_targets removeObject:target];
        [_targetIndexs removeObject:targetIndex];
    }
}

- (void)notifyTargetsNewOutputTexture:(CMTime)time {
    for (id<GPUInput> target in _targets) {
        NSInteger indexOfObject = [_targets indexOfObject:target];
        NSInteger textureIndex = [[_targetIndexs objectAtIndex:indexOfObject] integerValue];

        [target setInputSize:_textureSize atIndex:textureIndex];
        [target setInputFramebuffer:_outputFramebuffer atIndex:textureIndex];
        [target newFrameReadyAtTime:time atIndex:textureIndex];
    }
}

- (void)removeAllTargets {
    [_targets removeAllObjects];
    [_targetIndexs removeAllObjects];
}

@end
