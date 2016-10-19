//
//  XYAVFileTool.m
//  XYAVCacheLoaderExample
//
//  Created by xiaoyu on 2016/10/18.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import "XYAVFileTool.h"

@interface XYAVFileTool ()

@property (nonatomic, strong) NSFileHandle *writeFileHandle;
@property (nonatomic, strong) NSFileHandle *readFileHandle;

@end

@implementation XYAVFileTool

+ (BOOL)createTempFile {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * path = [self assetTempFilePath];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}

+ (void)writeTempFileData:(NSData *)data {
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:[self assetTempFilePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length {
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:[self assetTempFilePath]];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (void)cacheTempFileWithFileName:(NSString *)name {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * cacheFolderPath = [self assetCacheFolderPath];
    if (![manager fileExistsAtPath:cacheFolderPath]) {
        [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", cacheFolderPath, name];
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:[self assetTempFilePath] toPath:cacheFilePath error:nil];
    NSLog(@"cache file : %@", success ? @"success" : @"fail");
}

//+ (NSString *)cacheFileExistsWithURL:(NSURL *)url {
//    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [self assetCacheFolderPath], [self fileNameWithURL:url]];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
//        return cacheFilePath;
//    }
//    return nil;
//}

+ (NSString *)cacheFileExistsWithFileName:(NSString *)fileName pathExtension:(NSString *)pathExtension{
    if (pathExtension) {
        pathExtension = [NSString stringWithFormat:@".%@",pathExtension];
    }else{
        pathExtension = @"";
    }
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@%@", [self assetCacheFolderPath], fileName,pathExtension];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
}

+ (BOOL)clearCache {
    NSFileManager * manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:[self assetCacheFolderPath] error:nil];
}

+ (NSString *)assetTempFilePath {
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"XYAVMoviePlayerTmp.mp4"];
}

+ (NSString *)assetCacheFolderPath {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"movieCaches"];
}

//+ (NSString *)fileNameWithURL:(NSURL *)url {
//    return [[url.path componentsSeparatedByString:@"/"] lastObject];
//}

@end

@implementation NSURL (XYAVMoviePlayer)

- (NSURL *)customSchemeURL {
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

- (NSURL *)originalSchemeURL {
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    return [components URL];
}

@end
