//
//  NSObject+MethodSwizzlingCategory.m
//  MethodSwizzling
//
//  Created by lijian on 14-4-30.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "NSObject+MethodSwizzlingCategory.h"

@implementation NSObject (MethodSwizzlingCategory)

+ (BOOL)swizzleMethod:(SEL)oriSel withMethod:(SEL)altSel {
    Method oriMethod = class_getInstanceMethod(self, oriSel);
    
    if (!oriMethod) {
        NSLog(@"original method %@ not found for class %@", NSStringFromSelector(oriSel), NSStringFromClass(self));
        return NO;
    }
    
    Method altMethod = class_getInstanceMethod(self, altSel);
    
    if (!altMethod) {
        NSLog(@"alter method %@ not found for class %@", NSStringFromSelector(oriSel), NSStringFromClass(self));
        return NO;
    }
    
    class_addMethod(self, oriSel, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    class_addMethod(self, altSel, method_getImplementation(altMethod), method_getTypeEncoding(altMethod));
    
    method_exchangeImplementations(oriMethod, altMethod);
    
    return YES;
}

+ (BOOL)swizzleClassMethod:(SEL)oriSel withMethod:(SEL)altSel {
    Class c = object_getClass((id)self);
    return [c swizzleMethod:oriSel withMethod:altSel];
}

@end
