//
//  Bar.h
//  MethodSwizzling
//
//  Created by lijian on 14-4-30.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "Foo.h"

@interface Bar : Foo

- (void)testMethod;
- (void)recursionMethod;

@end


@interface Bar (BarCategory)

- (void)altTestMethod;
- (void)altBaseMethod;
- (void)altRecursionMethod;

@end
