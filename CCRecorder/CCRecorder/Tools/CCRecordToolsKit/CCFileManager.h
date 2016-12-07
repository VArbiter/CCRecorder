//
//  CCFileManager.h
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/4.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCFileManager : NSObject

+ (BOOL) ccCreateVideoFolderIfNotExist ;
+ (NSString *) ccGetVideoSaveFilePathString ;
+ (NSString *) ccGetVideoMergeFilePathString ;
+ (NSString *) ccGetVideoSaveFolderPathString ;

+ (void) ccDeleteWithFileURL : (NSURL *) urlFilePath
                   withBlock : (CCReloadBlock) block;

@end
