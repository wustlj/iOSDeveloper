//
//  MVParse.h
//  Movie
//
//  Created by lijian on 14/11/24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVParse : NSObject

+ (void)parse:(NSString *)path completionHandler:(void (^)(NSArray *))handler;

@end
