//
//  LrcParser.h
//  lrc
//
//  Created by lijian on 14-6-13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Lrc;

@interface LrcParser : NSObject

+ (Lrc *)parseLrcWithFilePath:(NSString *)path;

@end

@interface Lrc : NSObject
{
    NSArray *_sortedKeys;
    NSArray *_sortedValues;
}
@property (nonatomic, readonly) NSMutableDictionary *lyrics;
@property (nonatomic, readonly) NSMutableArray *tags;
@property (nonatomic, retain) NSString *offset;

+ (Lrc *)lrc;

@property (nonatomic, readonly) NSArray *sortedLrcKeys;
@property (nonatomic, readonly) NSArray *sortedLrcValues;

@end
