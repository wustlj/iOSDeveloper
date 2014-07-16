//
//  ViewController.m
//  runtime
//
//  Created by lijian on 14-2-24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

static NSArray * ClassMethodNames(Class c)
{
    NSMutableArray *array = [NSMutableArray array];
    
    unsigned int outCount = 0;
    Method *methodList = class_copyMethodList(c, &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        [array addObject:NSStringFromSelector(method_getName(methodList[i]))];
    }
    
    return array;
}

static void PrintDescription(NSString *name, id obj)
{
    Class c = object_getClass(obj);
    NSString *str = [NSString stringWithFormat:
                     @"\n\t%@: %@\n\tNSObject class %s\n\tlibobjc class %s\n\timplements methods <%@>", name, obj, class_getName([obj class]), class_getName(c), [ClassMethodNames(c) componentsJoinedByString:@","]];
    NSLog(@"%@", str);
}

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self printRuntime];
/*
    void (*setterX)(id, SEL, int);
    
    Foo *f = [[Foo alloc] init];
    
    setterX = (void (*)(id, SEL, int))[f methodForSelector:@selector(add:)];
    
    NSTimeInterval start = [[NSDate date] timeIntervalSinceNow];
    
    SEL sel = @selector(add:);
    
    for (int i = 0; i < 100000; i++) {
        setterX(f, sel, 3);
    }
    
    NSTimeInterval end = [[NSDate date] timeIntervalSinceNow];
    
    NSLog(@"duration : %f", end- start);
    
    NSTimeInterval start2 = [[NSDate date] timeIntervalSinceNow];
    
    for (int i = 0; i < 100000; i++) {
        [f add:3];
    }
    
    NSTimeInterval end2 = [[NSDate date] timeIntervalSinceNow];

    NSLog(@"duration2 : %f", end2- start2);

    
    NSLog(@"%d", f->count);
*/    
    NSArray *array = [[NSArray alloc] initWithObjects:@"1", @"2", nil];
    NSLog(@"A: %@", array);
    
    NSArray *a = array;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"B: %@", a);
    });
    
    NSLog(@"C: %@", array);

}

- (void)printRuntimeForKVO {
    Foo *anything = [[Foo alloc] init];
    Foo *x = [[Foo alloc] init];
    Foo *y = [[Foo alloc] init];
    Foo *xy = [[Foo alloc] init];
    Foo *control = [[Foo alloc] init];
    
    [x addObserver:anything forKeyPath:@"x" options:0 context:NULL];
    [y addObserver:anything forKeyPath:@"y" options:0 context:NULL];
    
    [xy addObserver:anything forKeyPath:@"x" options:0 context:NULL];
    [xy addObserver:anything forKeyPath:@"y" options:0 context:NULL];
    
    PrintDescription(@"control", control);
    PrintDescription(@"x", x);
    PrintDescription(@"y", y);
    PrintDescription(@"xy", xy);
    
    NSLog(@"\n\tUsing NSObject methods,normal setX: is %p, overridden setX: is %p\n", [control methodForSelector:@selector(setX:)], [x methodForSelector:@selector(setX:)]);
    
    NSLog(@"\n\tUsing libobjc functions, normal setX: is %p, overridden setX: is %p\n", method_getImplementation(class_getInstanceMethod(object_getClass(control), @selector(setX:))), method_getImplementation(class_getInstanceMethod(object_getClass(x), @selector(setX:))));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
