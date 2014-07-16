//
//  LrcParser.m
//  lrc
//
//  Created by lijian on 14-6-13.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "LrcParser.h"

@implementation LrcParser

+ (Lrc *)parseLrcWithFilePath:(NSString *)path {
    if (path == nil || ![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO]) {
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableString *lrcString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    Lrc *lrc = [Lrc lrc];
    
#ifdef DEBUG
    NSLog(@"lrc string:\n%@", lrcString);
#endif
    
    while (lrcString && lrcString.length > 0) {
        if ([lrcString hasPrefix:@"[ti:"] || [lrcString hasPrefix:@"[ar:"] || [lrcString hasPrefix:@"[al:"] || [lrcString hasPrefix:@"[by:"]) {
            NSRange r = [lrcString rangeOfString:@"]"];
            NSAssert(r.location != NSNotFound, @"lrc format error");
            NSString *tag = [lrcString substringWithRange:(NSRange){4, r.location - 4}];
            [lrc.tags addObject:tag];
            [lrcString deleteCharactersInRange:(NSRange){0, r.location + r.length}];
            r = [lrcString rangeOfString:@"["];
            if (r.location != NSNotFound) {
                [lrcString deleteCharactersInRange:(NSRange){0,r.location}];
            }
            continue;
        } else if ([lrcString hasPrefix:@"[offset:"]) {
            NSRange r = [lrcString rangeOfString:@"]"];
            NSAssert(r.location != NSNotFound, @"lrc format error");
            NSString *offset = [lrcString substringWithRange:(NSRange){8, r.location - 8}];
            lrc.offset = offset;
            [lrcString deleteCharactersInRange:(NSRange){0, r.location + r.length}];
            r = [lrcString rangeOfString:@"["];
            if (r.location != NSNotFound) {
                [lrcString deleteCharactersInRange:(NSRange){0,r.location}];
            }
            continue;
        } else {
            NSAssert([lrcString hasPrefix:@"["], @"lrc format error");
            NSMutableArray *keys = [NSMutableArray array];
            NSRange r;
            while ([lrcString hasPrefix:@"["]) {
                r = [lrcString rangeOfString:@"]"];
                NSAssert(r.location != NSNotFound, @"lrc format error");
                NSString *key = [lrcString substringWithRange:(NSRange){1, r.location - 1}];
                [keys addObject:key];
                [lrcString deleteCharactersInRange:(NSRange){0, r.location + r.length}];
            }
            r = [lrcString rangeOfString:@"["];
            NSString *value = nil;
            if (r.location != NSNotFound) {
                value = [lrcString substringToIndex:r.location - 1];
            } else {
                value = [lrcString substringToIndex:lrcString.length];
                r.location = lrcString.length;
            }
            
            [lrcString deleteCharactersInRange:(NSRange){0, r.location}];
            NSAssert(value != nil, @"lrc format error");
            
            if (value && [value length] == 0) {
                continue;
            }
            
            for (NSString *key in keys) {
                if (!key || [key length] < 3 || [key rangeOfString:@":"].location == NSNotFound) {
                    continue;
                }
                float k = [[key substringToIndex:2] intValue]*60+[[key substringFromIndex:3] floatValue];
//                if (k < 0.01) {
//                    continue;
//                }
                [lrc.lyrics setObject:value forKey:[NSNumber numberWithFloat:k]];
            }
            continue;
        }
    }
        
    return lrc;
}

@end

@implementation Lrc

+ (Lrc *)lrc {
    return [[[Lrc alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    if (self) {
        _lyrics = [[NSMutableDictionary alloc] init];
        _tags = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_lyrics release];
    [_tags release];
    
    [_sortedValues release];
    [_sortedKeys release];
    
    [super dealloc];
}

- (NSArray *)sortedLrcKeys {
    if (!_sortedKeys) {
        _sortedKeys = [[self sortedLyricKeys] retain];
    }
    
    return _sortedKeys;
}

- (NSArray *)sortedLrcValues {
    if (!_sortedValues) {
        _sortedValues = [[self sortedLyricValues] retain];
    }
    return _sortedValues;
}

- (NSArray *)sortedLyricKeys {
    NSArray *keys = [_lyrics allKeys];
    
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 floatValue] > [obj2 floatValue]) {
            return NSOrderedDescending;
        }
        if ([obj1 floatValue] < [obj2 floatValue]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    return sortedKeys;
}

- (NSArray *)sortedLyricValues {
    NSArray *keys = [self sortedLyricKeys];
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString *key in keys) {
        [values addObject:[_lyrics objectForKey:key]];
    }
    
    return [NSArray arrayWithArray:values];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"tag:%@\noffset:%@\nlrc:%@", _tags, _offset, _lyrics];
}

@end
