//
//  CCCommonDefine.h
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/22.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+CCRecordToolsKit.h"

/// 调试输出
#if DEBUG
#define CCLog(...) NSLog(__VA_ARGS__)
//#define CCError(Error) if (Error) {NSLog(@"%d , %s , %@" ,__LINE__,__FUNCTION__,error);}
#else
#define CCLog(...) /* */
//#define CCError(Error) /* */
#endif

/// self 弱引用
#define ccWeakSelf __weak typeof(&*self) pSelf = self

/// 字符串格式化
#define ccStringFormat(...) [NSString stringWithFormat:__VA_ARGS__]

NS_ASSUME_NONNULL_BEGIN

/// 回调刷新 公用 Block
typedef void(^CCReloadBlock)(BOOL succeed , id _Nullable item);

@interface CCCommonDefine : NSObject

/// 判断是否为 iOS 9 , YES 为 是 , NO 为 不是
BOOL _ccIsiOS9();

/// 屏幕 Frame
CGRect _ccScreenBounds();
/// 屏幕高
CGFloat _ccScreenHeight();
/// 屏幕宽
CGFloat _ccScreenWidth();
/// 转化为字符串对象
NSString  *_ccForUTF8String(const char * string);
/// 转化为 NSURL 对象
NSURL *_ccForURL(NSString * string , BOOL isFile);
/// 录制窗口大小
CGSize _ccRecordViewSize();
/// 返回颜色
UIColor *_ccColor(CGFloat r, CGFloat g , CGFloat b , CGFloat a);

/// 录制视频最大时长 , 单位 秒
CGFloat _ccMaxDuration();
/// 录制视频最小时长 , 单位 秒
CGFloat _ccMinDuration();
/// 监视秒相加间隔
CGFloat _ccTimerDuration();

/// 给颜色举例 若颜色为 : #ffffff 则输入 0xffffff
UIColor * _ccHexColor(int intValue ,float floatAlpha);

/// 便捷拼接多个字符串 eg: input: @"1"@"2"@"3" , @return : @"123"
NSString * _ccMergeString(NSString * string , ...);

UIImage * _ccImage(NSString * imageName , BOOL isFile);

NSBundle *_Nullable _ccBundle();

NSString * _ccFilePath(NSString *stringFileName , NSString *stringFileType);

UIImage * _ccImagePath(NSString *stringImageName);

@end

NS_ASSUME_NONNULL_END
