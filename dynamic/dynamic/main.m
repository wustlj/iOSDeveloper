//
//  main.m
//  dynamic
//
//  Created by wustlj on 14-3-26.
//  Copyright (c) 2014年 wustlj. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>



@interface Foo : NSObject

@property (nonatomic) float height;

@end

void dynamicMethod(id s, SEL sel, float w) {
    NSLog(@"%@", NSStringFromSelector(sel));
    NSLog(@"%f", w);
}

float dynamicGetMethod(id s, SEL sel) {
    NSLog(@"%@", NSStringFromSelector(sel));
    return 111.0f;
}



@implementation Foo

@dynamic height;

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    BOOL result = NO;
    if (sel == @selector(setHeight:)) {
        class_addMethod([self class], sel, (IMP)dynamicMethod, "v@:f");
        result = YES;
    } else if (sel == @selector(height)) {
        class_addMethod([self class], sel, (IMP)dynamicGetMethod, "f@:");
        result = YES;
    }
    return result;
}

@end



int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        Foo *f = [[Foo alloc] init];
        [f setHeight:3.0f];
        
        NSLog(@"%f", f.height);
        
    }
    return 0;
}

