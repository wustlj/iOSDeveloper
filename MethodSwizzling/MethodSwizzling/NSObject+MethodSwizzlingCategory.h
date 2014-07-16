//
//  NSObject+MethodSwizzlingCategory.h
//  MethodSwizzling
//
//  Created by lijian on 14-4-30.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (MethodSwizzlingCategory)

+ (BOOL)swizzleMethod:(SEL)oriSel withMethod:(SEL)altSel;
+ (BOOL)swizzleClassMethod:(SEL)oriSel withMethod:(SEL)altSel;

@end
