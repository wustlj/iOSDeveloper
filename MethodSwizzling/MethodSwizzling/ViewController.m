//
//  ViewController.m
//  MethodSwizzling
//
//  Created by lijian on 14-4-30.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(xxx_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
//        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//        
//        if (didAddMethod) {
//            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
//        }
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!_foo) {
        _foo = [[Foo alloc] init];
    }
    
    if (!_bar) {
        _bar = [[Bar alloc] init];
    }
    NSLog(@"~~~~~~~~~~~~~~~1~~~~~~~~~~~~~~~");
    [_foo testMethod];
    [_bar testMethod];
    [_bar altTestMethod];
    
    NSLog(@"~~~~~~~~~~~~~~~2~~~~~~~~~~~~~~~");
    [Foo swizzleMethod:@selector(testMethod) withMethod:@selector(altTestMethod)];
    [_foo testMethod];
    [_bar testMethod];
    [_bar altTestMethod];
    
    NSLog(@"~~~~~~~~~~~~~~~3~~~~~~~~~~~~~~~");
    [Bar swizzleMethod:@selector(testMethod) withMethod:@selector(altTestMethod)];
    [_foo testMethod];
    [_bar testMethod];
    [_bar altTestMethod];
    
    NSLog(@"~~~~~~~~~~~~~~~4~~~~~~~~~~~~~~~");
    [_foo baseMethod];
    [_bar baseMethod];
    [_bar altBaseMethod];
    
    NSLog(@"~~~~~~~~~~~~~~~5~~~~~~~~~~~~~~~");
    [Bar swizzleMethod:@selector(baseMethod) withMethod:@selector(altBaseMethod)];
    [_foo baseMethod];
    [_bar baseMethod];
    [_bar altBaseMethod];

    NSLog(@"~~~~~~~~~~~~~~~6~~~~~~~~~~~~~~~");
    [Bar swizzleMethod:@selector(recursionMethod) withMethod:@selector(altRecursionMethod)];
    [_bar altRecursionMethod];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"2222");
}

- (void)xxx_viewWillAppear:(BOOL)animated {
    [self xxx_viewWillAppear:animated];
    
    NSLog(@"1111");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
