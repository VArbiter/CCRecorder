//
//  CCRecorderHandler.h
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/8.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCCommonDefine.h"

@class CCRecorderHandler;
@class GPUImageView;
@class UIView;

typedef NS_ENUM(NSInteger , CCTorchMode) {
    CCTorchModeOn = 0 ,
    CCTorchModeAuto ,
    CCTorchModeOff
};

typedef NS_ENUM(NSInteger , CCCrashCode) {
    CCCrashCodeStopRecordingError = 10000 ,
    CCCrashCodeStartRecordingError ,
    CCCrashCodeMergingFileError ,
    CCCrashCodeDeleteLastFileError ,
    CCCrashCodeDeleteAllFileError
};

@protocol  CCRecorderHandlerDelegate <NSObject>

@optional

/**
 *  recorder开始录制一段视频时
 *
 *  @param videoRecorder 录制对象
 *  @param fileURL       开始录制时的文件路径
 */
- (void)ccVideoRecorder:(CCRecorderHandler *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL;

/**
 *  recorder完成一段视频的录制时
 *
 *  @param videoRecorder 录制对象
 *  @param outputFileURL 输出文件路径
 *  @param videoDuration 视频长度
 *  @param totalDur      视频总长度
 *  @param error         错误信息
 */
- (void)ccVideoRecorder:(CCRecorderHandler *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error;

/**
 *  recorder正在录制的过程中
 *
 *  @param videoRecorder 录制对象
 *  @param outputFileURL 输出文件路径
 *  @param videoDuration 视频长度
 *  @param totalDur      视频总长度
 */
- (void)ccVideoRecorder:(CCRecorderHandler *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur;

/**
 *  recorder删除了某一段视频
 *
 *  @param videoRecorder 录制对象
 *  @param fileURL       文件路径
 *  @param totalDur      视频总时长
 *  @param error         错误信息
 */
- (void)ccVideoRecorder:(CCRecorderHandler *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error;
/**
 *  合成结束输出路径
 *
 *  @param videoRecorder 录制对象
 *  @param outputFileURL 合成文件的路径
 */
- (void)ccVideoRecorder : (CCRecorderHandler *)videoRecorder didFinishMergingVideosToOutPutFileAtURL : (NSURL *)outputFileURL ;

@end

@interface CCRecorderHandler : NSObject

@property (nonatomic , assign) id<CCRecorderHandlerDelegate> delegate;

@property (nonatomic , strong , readonly) GPUImageView *viewOutput;

/**
 *  是否正在录制
 *  如果正在录制 , 则不允许切换摄像头 和 美颜
 *  如果停止录制 , 则允许切换摄像头 和 美颜
 */
@property (nonatomic , assign , readonly) BOOL isRecording;

/**
 *  录制文件数组
 */
@property (nonatomic , strong , readonly) NSMutableArray *arrayVideoFiles;

/// 单例不能销毁 , 慎用 , 可以选择使用 [[Class alloc] init]
+ (instancetype) sharedCCRecorderHandler;

/// 准备录制视频
- (void) ccRHPrepareToRecordWithOutputView : (UIView *) viewPrepare ;

/// 开始录制视频
- (void) ccRHStartRecording;

/// 结束录制视频
- (void) ccRHStopRecording ;

/// 合成视频
- (void) ccRHMergeVideos;

/// 暂停摄像
- (void) ccRHPauseCapture;

/// 恢复摄像
- (void) ccRHResumeCapture;

/**
 *  设置闪光灯
 *
 *  @param torchMode 闪光灯模式
 */
- (void) ccRHSetTorchWithTorchMode : (CCTorchMode) torchMode ;

/**
 *  设置对焦
 *
 *  @param touchPoint 手指点击的地方
 */
- (void) ccRHFocusInPoint : (CGPoint)touchPoint;

/**
 *  变换前后摄像机
 *
 *  @param isFront YES 是前 , NO 是后 .
 */
- (void) ccRHChangeCamera ;

/// 添加美颜
- (void) ccRHAddBeautyFilter ;

/// 删除最后一段视频
- (void) ccRHDeleteLastVideo ;

/// 删除所有视频
- (void) ccRHDeleteAllVideos ;

/// 相机是否启用
+ (BOOL) ccIsCameraAllowed ;

/// 麦克风是否启用
+ (BOOL) ccIsMicroPhoneAllowed ;

/// 打开相机权限申请设置
+ (void) ccGuideToCameraSettings ;


@end

#pragma mark - 设置 Video 的 信息
@interface CCVideoInfo : NSObject

@property (nonatomic , assign) CGFloat floatDuration;
@property (nonatomic , strong) NSURL *urlFilePath;

@end

