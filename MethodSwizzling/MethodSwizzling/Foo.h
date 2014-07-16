//
//  Foo.h
//  MethodSwizzling
//
//  Created by lijian on 14-4-30.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LogTrace() NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))

@interface Foo : NSObject


- (void)testMethod;

- (void)baseMethod;

- (void)recursionMethod;

@end
