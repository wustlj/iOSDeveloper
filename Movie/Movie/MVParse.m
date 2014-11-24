//
//  MVParse.m
//  Movie
//
//  Created by lijian on 14/11/24.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "MVParse.h"

#import "JSONKit.h"

#define SOURCE_KEY @""

@implementation MVParse

+ (void)parse:(NSString *)path completionHandler:(void (^)(NSArray *))handler {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        NSDictionary *dic = [data objectFromJSONData];
        NSArray *arr = [dic objectForKey:@"sources"];
        NSMutableArray *movies = [NSMutableArray arrayWithCapacity:[arr count]];
        for (NSString *name in arr) {
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]]];
            [movies addObject:url];
        }
        handler(movies);
    }
}

@end
