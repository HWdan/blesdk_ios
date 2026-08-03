//
//  AiFileUtils.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/10.
//

#import "AiFileUtils.h"
#import <SSZipArchive/SSZipArchive.h>

@implementation AiFileUtils

+ (NSString *) generatePreviewZip:(NSString *)previewBinPath
{
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *zipFilePath = [cacheDir stringByAppendingPathComponent:@"target.zip"];
    
    [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
    
    // 创建一个临时目录来存储需要压缩的文件
    NSString *tempDirectory = [cacheDir stringByAppendingPathComponent:@"tempZipFolder"];
    // 创建临时目录
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"Failed to create temp directory: %@", error.localizedDescription); return nil;
    }
    
    // 将目录1复制到临时目录，并保留目录结构
    [self copyFile:previewBinPath toDestination:tempDirectory withBaseFolder:@"dyn/ai/"];
    NSArray *tempContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempDirectory error:nil];
    NSLog(@"Temp dir contents before zip: %@", tempContents);
    // 使用 SSZipArchive 压缩临时目录
    [SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:tempDirectory];
    // 删除临时目录
    [[NSFileManager defaultManager] removeItemAtPath:tempDirectory error:nil];
    NSLog(@"Zip file created at: %@", zipFilePath);
    return zipFilePath;
}

// 辅助方法：将目录中的文件复制到目标目录，并设置子目录路径
+ (void)copyFile:(NSString *)filePath
   toDestination:(NSString *)destinationPath
  withBaseFolder:(NSString *)baseFolder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 如果是文件，则直接复制到目标路径 // 确保目标路径存在
    NSLog(@"Copying file: %@", filePath);
    NSString *destinationItemPath = [destinationPath stringByAppendingPathComponent:[baseFolder stringByAppendingPathComponent:[filePath lastPathComponent]]];
    NSString *destinationDirectory = [destinationItemPath stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:destinationDirectory]) {
        [fileManager createDirectoryAtPath:destinationDirectory withIntermediateDirectories:YES attributes:nil error:nil]; }
    // 复制文件
    [fileManager copyItemAtPath:filePath toPath:destinationItemPath error:nil];
}


+ (NSString *) generateTextToVoicePath
{
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [cacheDir stringByAppendingPathComponent:@"text_to_voice"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }    
    return path;
}


@end
