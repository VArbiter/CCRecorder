//
//  CCFileManager.m
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/4.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import "CCFileManager.h"

@interface CCFileManager ()

NSString * _ccFolderVideoName();

NSString * _ccGetGetVideoSaveFolderPath();

@end

@implementation CCFileManager

+ (BOOL) ccCreateVideoFolderIfNotExist {
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringFolderMainPath = [arrayPaths firstObject];
    
    NSString *stringFolderPath = [stringFolderMainPath stringByAppendingPathComponent:_ccFolderVideoName()];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isFolder = FALSE;
    BOOL isFolderExist = [fileManager fileExistsAtPath:stringFolderPath isDirectory:&isFolder];
    
    if(!(isFolderExist && isFolder))
    {
        BOOL isFolderCreated = [fileManager createDirectoryAtPath:stringFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!isFolderCreated){
            NSLog(@"创建图片文件夹失败");
            return NO;
        }
        return YES;
    }
    return YES;
}
+ (NSString *) ccGetVideoSaveFilePathString {
    NSString * stringFolderMainPath = _ccGetGetVideoSaveFolderPath();
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[stringFolderMainPath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    
    return fileName;
}
+ (NSString *) ccGetVideoMergeFilePathString {
    NSString * stringFolderMainPath = _ccGetGetVideoSaveFolderPath();
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[stringFolderMainPath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    return fileName;
}
+ (NSString *) ccGetVideoSaveFolderPathString {
    return _ccGetGetVideoSaveFolderPath();
}

#pragma mark - Private Method (s)
NSString * _ccFolderVideoName(){
    return @"Videos";
}

NSString * _ccGetGetVideoSaveFolderPath(){
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringFolderMainPath = [arrayPaths firstObject];
    
    stringFolderMainPath = [stringFolderMainPath stringByAppendingPathComponent:_ccFolderVideoName()];
    return stringFolderMainPath;
}

@end
