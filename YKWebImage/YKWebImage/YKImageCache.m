//
//  YKImageCache.m
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import "YKImageCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface YKImageCache ()
{
    NSFileManager *_fileManager;
    NSString *_dirPath;
}
@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, strong) dispatch_queue_t ioQueue;

@end

@implementation YKImageCache

+ (YKImageCache *)shareInstance {
    static dispatch_once_t onceToken;
    static YKImageCache *instance;
    dispatch_once(&onceToken, ^{
        instance = [[YKImageCache alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _shouldCacheInMemory = YES;
        _memCache = [[NSCache alloc] init];
        _ioQueue = dispatch_queue_create("com.youku.ykimage.cache", DISPATCH_QUEUE_SERIAL);
        [self setupDirectoryPath];
        _fileManager = [[NSFileManager alloc] init];
    }
    return self;
}

- (void)setupDirectoryPath {
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _dirPath = [[array firstObject] stringByAppendingPathComponent:@"com.youku.ykimage.cache"];
}

- (NSString *)fileNameForKey:(NSString *)key {
    const char *cStr = [key UTF8String];
    if (cStr == NULL) {
        cStr = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), r);
    NSString *ext = [key pathExtension];
    NSString *fileType = [ext isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", ext];
    NSString *fileName = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15],
                          fileType
                          ];
    return fileName;
}

- (NSString *)filePathForKey:(NSString *)key {
    return [_dirPath stringByAppendingPathComponent:[self fileNameForKey:key]];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key {
    if (!image || !key) return;
    
    if (self.shouldCacheInMemory) {
        [self.memCache setObject:image forKey:key];
    }
    
    dispatch_async(self.ioQueue, ^{
        NSData *data = UIImagePNGRepresentation(image);
        
        if (data) {
            NSString *filePath = [self filePathForKey:key];
            
            if (![_fileManager fileExistsAtPath:_dirPath]) {
                [_fileManager createDirectoryAtPath:_dirPath withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            
            [_fileManager createFileAtPath:filePath contents:data attributes:nil];
        }
    });
}

- (void)removeImageForKey:(NSString *)key {
    if (!key) return;
    
    if (self.shouldCacheInMemory) {
        [self.memCache removeObjectForKey:key];
    }
    
    dispatch_async(self.ioQueue, ^{
        NSString *filePath = [self filePathForKey:key];
        [_fileManager removeItemAtPath:filePath error:NULL];
    });
    
}

- (UIImage *)imageFromCacheForKey:(NSString *)key {
    UIImage *image = [self.memCache objectForKey:key];
    if (image) {
        return image;
    }
    
    NSString *filePath = [self filePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    if (data) {
        image = [UIImage imageWithData:data];
        return image;
    }
    
    return nil;
}

- (void)cleanCache {
    [self.memCache removeAllObjects];
    
    dispatch_async(self.ioQueue, ^{
        [_fileManager removeItemAtPath:_dirPath error:NULL];
    });
}

@end