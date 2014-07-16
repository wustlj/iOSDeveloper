//
//  Bar.m
//  MethodSwizzling
//
//  Created by lijian on 14-4-30.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "Bar.h"

@implementation Bar

- (void)testMethod {
    LogTrace();
}

//- (void)recursionMethod {
//    LogTrace();
//}

@end

@implementation Bar (BarCategory)

- (void)altBaseMethod {
    NSLog(@"Bar (BarCategory) altBaseMethod");
}

- (void)altTestMethod {
    NSLog(@"Bar (BarCategory) altTestMethod");
}

- (void)altRecursionMethod {
    NSLog(@"Bar (BarCategory) altRecursionMethod");
    
    [self altRecursionMethod];
}

@end