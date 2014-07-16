//
//  ViewController.h
//  MethodSwizzling
//
//  Created by lijian on 14-4-30.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foo.h"
#import "Bar.h"
#import "NSObject+MethodSwizzlingCategory.h"

@interface ViewController : UIViewController
{
    Foo *_foo;
    Bar *_bar;
}
@end
