//
//  Foo.m
//  MethodSwizzling
//
//  Created by lijian on 14-4-30.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "Foo.h"

@implementation Foo

- (void)testMethod {
    LogTrace();
}

- (void)baseMethod {
    LogTrace();
}

- (void)recursionMethod {
    LogTrace();
}

@end
