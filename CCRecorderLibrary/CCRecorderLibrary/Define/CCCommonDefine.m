//
//  CCCommonDefine.m
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/22.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import "CCCommonDefine.h"

@interface CCCommonDefine ()

@end

@implementation CCCommonDefine

BOOL _ccIsiOS9() {
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 ? YES : NO;
}

CGRect _ccScreenBounds(){
    return [[UIScreen mainScreen] applicationFrame];
}
CGFloat _ccScreenHeight(){
    return [UIScreen mainScreen].bounds.size.height;
}
CGFloat _ccScreenWidth(){
    return [UIScreen mainScreen].bounds.size.width;
}
NSString  *_ccForUTF8String(const char * string){
    return [NSString stringWithUTF8String:string];
}
NSURL *_ccForURL(NSString * string , BOOL isFile){
    return isFile ? [NSURL fileURLWithPath:string] : [NSURL URLWithString:string];
}
CGSize _ccRecordViewSize(){
    return CGSizeMake(480.0f, 480.0f);
}

UIColor *_ccColor(CGFloat r, CGFloat g , CGFloat b , CGFloat a){
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a];
}

CGFloat _ccMaxDuration(){
    return 10.0f;
}

CGFloat _ccMinDuration(){
    return 4.0f;
}

CGFloat _ccTimerDuration(){
    return 0.05f;
}

UIColor * _ccHexColor(int intValue ,float floatAlpha){
    return [UIColor colorWithRed:((CGFloat)((intValue & 0xFF0000) >> 16))/255.0 green:((CGFloat)((intValue & 0xFF00) >> 8))/255.0 blue:((CGFloat)(intValue & 0xFF))/255.0 alpha:(CGFloat)floatAlpha];
}

NSString * _ccMergeString(NSString * string , ...) {
    return string;
}

UIImage * _ccImage(NSString * imageName , BOOL isFile){
    return isFile ? [UIImage imageWithContentsOfFile:imageName] : [UIImage imageNamed:imageName];
}

NSBundle *_ccBundle(){
    return [NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"CCRecordViewController")]pathForResource:@"CCRecorderLibraryBundle" ofType:@"bundle"]];
}

NSString * _ccFilePath(NSString *stringFileName , NSString *stringFileType){
    return [_ccBundle() pathForResource:stringFileName ofType:stringFileType];
}

UIImage * _ccImagePath(NSString *stringImageName) {
    CGFloat floatScale = 2.0f;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        floatScale = [[UIScreen mainScreen] scale];
    NSString *stringPath = [NSString stringWithFormat:@"%@%@.tiff", stringImageName , floatScale > 2.f ? @"@3x" : @"@2x"];
    NSString *stringFullPath = [[_ccBundle() resourcePath] stringByAppendingPathComponent:stringPath];
    UIImage *image = [UIImage imageWithCGImage:[UIImage imageWithContentsOfFile:stringFullPath].CGImage
                                         scale:floatScale
                                   orientation:UIImageOrientationUp];
    return image;
}

@end
