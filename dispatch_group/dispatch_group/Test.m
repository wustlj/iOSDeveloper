//
//  Test.m
//  dispatch_group
//
//  Created by lijian on 14/11/5.
//  Copyright (c) 2014年 youku. All rights reserved.
//

#import "Test.h"

@implementation Test

- (void)loadAsyn:(NSString *)num completionHandler:(void (^)(void))handler
{
    dispatch_async(dispatch_queue_create("xx", NULL), ^{
        int n = [num intValue];
        int total;
        for (int i = 1; i <= n; i++) {
            total += n;
        }
        NSLog(@"1~%d total %d", n, total);
        handler();
    });
}

@end
