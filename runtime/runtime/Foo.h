//
//  Foo.h
//  runtime
//
//  Created by lijian on 14-2-24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Foo : NSObject
{
    @public
    int x;
    int y;
    int z;
    int count;
}

@property int x;
@property int y;
@property int z;

- (void)add:(int)a;

@end
