//
//  Test.h
//  dispatch_group
//
//  Created by lijian on 14/11/5.
//  Copyright (c) 2014年 youku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Test : NSObject

- (void)loadAsyn:(NSString *)num completionHandler:(void (^)(void))handler;

@end
