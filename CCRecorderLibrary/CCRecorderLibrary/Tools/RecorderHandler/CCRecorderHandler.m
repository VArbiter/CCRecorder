//
//  CCRecorderHandler.m
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/8.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import "CCRecorderHandler.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"

static CCRecorderHandler *_handler = nil;

@interface CCRecorderHandler () {
    BOOL _isBeautyOn;
    BOOL _isFront;
    BOOL _isTorchOn;
}

@property (nonatomic , strong) GPUImageVideoCamera *videoCamera;

@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;

@property (nonatomic , strong) GPUImageOutput<GPUImageInput> *filter;

@property (nonatomic , strong) GPUImageBilateralFilter *bilateraFilter;

@property (nonatomic , strong) GPUImageGaussianBlurFilter *gaussianBlurFilter;

@property (nonatomic , strong) GPUImageFilterGroup *filterGroup;

@property (nonatomic , strong , readwrite) NSMutableArray *arrayVideoFiles;

@property (nonatomic , strong) NSURL *urlCurrentFile;

@property (nonatomic , assign) CGFloat floatTotalDuration;

@property (nonatomic , assign) CGFloat floatCurrentVideoDuration;

@property (nonatomic , strong) NSTimer *timer;

@property (nonatomic , assign , readwrite) BOOL isRecording;

@property (nonatomic , strong) UIImageView *imageViewFocus;

@property (nonatomic , strong) UIView *viewPrepare;

- (void) ccDefaultSettings ;

- (NSString *) ccGetVideoMergeFilePathString ;

- (void) ccStartTimerCount ;

- (void) ccTimerAction ;

- (void) ccStopTimerCount ;

- (void) ccOperationWhenFailWithError : (NSError *) error ;

/**
 *  根据文件路径初始化写入 , 同时生成文件名
 */
- (void) ccAddMovieWriter ;

/**
 *  展示对焦框
 *
 *  @param pointFocus 对焦点
 */
- (void) ccShowFocusPointAtRect : (CGPoint) pointFocus;

/**
 *  根据摄像机位置进行初始化
 *
 *  @param position 摄像机设备位置
 */
- (void) ccInitVideoCamera ;


/**
 *  将录制好的多个视频合成为一个视频
 *
 *  @param fileURLArray 存放 File 路径的数组
 */
- (void)ccMergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray ;

/**
 *  转换坐标
 *
 *  @param viewCoordinates 点击的坐标
 *
 *  @return 显示的坐标
 */
- (CGPoint)ccConvertToPointOfInterestFromViewCoordinates : (CGPoint) viewCoordinates ;

/**
 *  设置对焦
 *
 *  @param focusMode                对焦模式
 *  @param exposureMode             曝光模式
 *  @param point                    对焦点
 *  @param monitorSubjectAreaChange 监视区域变化
 */
- (void)ccFocusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange;

/**
 *  删除视频
 *
 *  @param urlFilePath 文件路径
 */
- (void) ccDeleteWithFileURL : (NSURL *) urlFilePath ;

/**
 *  合成视频时 , 判断文件是否存在
 *
 *  @param urlFilePath 文件路径
 *
 *  @return YES 存在 , NO 不存在
 */
- (BOOL) ccIsFileExistAtURL : (NSURL *) urlFilePath ;

@end

@implementation CCRecorderHandler

+ (instancetype) sharedCCRecorderHandler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler = [[CCRecorderHandler alloc] init];
        [_handler ccDefaultSettings];
    });
    return _handler;
}

- (void) ccRHPrepareToRecordWithOutputView : (UIView *) viewPrepare {
#warning CHANGE >>> ADD DEFAULT SIZE WHEN CUSTOM
    viewPrepare.width = _ccScreenWidth();
    
    _viewPrepare = viewPrepare;
    
    _viewOutput = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, viewPrepare.width, viewPrepare.width)];
    _viewOutput.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [viewPrepare addSubview:(UIView *)_viewOutput];
    
    _imageViewFocus = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    _imageViewFocus.image = _ccImage(@"Icon_Focus", NO);
    _imageViewFocus.contentMode = UIViewContentModeScaleToFill;
    _imageViewFocus.alpha = 0.0f;
    [_viewPrepare addSubview:_imageViewFocus];
    
    _isTorchOn = NO;
    _floatTotalDuration = 0.0f;
    
    _filter = [[GPUImageFilter alloc] init];
    
    [self ccInitVideoCamera];
    
    [_videoCamera addTarget:_filter];
    
    [_filter addTarget:_viewOutput];
    
    [_videoCamera startCameraCapture];
    
    [self ccAddMovieWriter];
    
    [self ccRHAddBeautyFilter];
}

- (void) ccRHStartRecording {
    
    if (_isRecording) {
        return ;
    }
    CCLog(@"%@",_movieWriter);
    
    [self ccStartTimerCount];
//    [self ccAddMovieWriter];
    [_movieWriter startRecording];
    
    if ([_delegate respondsToSelector:@selector(ccVideoRecorder:didStartRecordingToOutPutFileAtURL:)]) {
        [_delegate ccVideoRecorder:self didStartRecordingToOutPutFileAtURL:_urlCurrentFile];
    }
    
    _isRecording = YES;
}

- (void) ccRHStopRecording {
    CCLog(@"_filter -.- %ld",(unsigned long)[[_filter targets] count]);
    CCLog(@"_filterGroup -.- %ld",(unsigned long)[[_filterGroup targets] count]);
    
    [self ccStopTimerCount];
    
    if (_floatCurrentVideoDuration < 0.15f) {
        [_movieWriter cancelRecording];
        
        if (_movieWriter) {
            [_filter removeTarget:_movieWriter];
            [_filterGroup removeTarget:_movieWriter];
            [_filter removeTarget:_movieWriter];
        }
        
        CCLog(@"_floatTotalDuration %lf , _floatCurrentVideoDuration %lf",_floatTotalDuration,_floatCurrentVideoDuration);
        
        [self ccOperationWhenFailWithError:nil];
        
        ccWeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            pSelf.isRecording = NO;
            [pSelf ccAddMovieWriter];
        });
    }
    
    ccWeakSelf;
    [_movieWriter finishRecordingWithCompletionHandler:^{
        
        CCVideoInfo *videoInfo = [[CCVideoInfo alloc] init];
        videoInfo.urlFilePath = pSelf.urlCurrentFile;
        videoInfo.floatDuration = pSelf.floatCurrentVideoDuration;
        
        [pSelf.arrayVideoFiles addObject:videoInfo];
        
        pSelf.floatTotalDuration += pSelf.floatCurrentVideoDuration;
        
        pSelf.isRecording = NO;
        
        if ([pSelf.delegate respondsToSelector:@selector(ccVideoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
            [pSelf.delegate ccVideoRecorder:pSelf didFinishRecordingToOutPutFileAtURL:pSelf.urlCurrentFile duration:pSelf.floatCurrentVideoDuration totalDur:pSelf.floatTotalDuration error:nil];
        }
        
        [pSelf ccAddMovieWriter];
    }];
    /*
    CCVideoInfo *videoInfo = [[CCVideoInfo alloc] init];
    videoInfo.urlFilePath = _urlCurrentFile;
    videoInfo.floatDuration = _floatCurrentVideoDuration;
    
    [_arrayVideoFiles addObject:videoInfo];
    
    _floatTotalDuration += _floatCurrentVideoDuration;
    
    _isRecording = NO;
    
    if ([_delegate respondsToSelector:@selector(ccVideoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
        [_delegate ccVideoRecorder:self didFinishRecordingToOutPutFileAtURL:_urlCurrentFile duration:_floatCurrentVideoDuration totalDur:_floatTotalDuration error:nil];
    }
    
    [self ccAddMovieWriter];
   */
    _movieWriter.failureBlock = ^(NSError *error) {
        [pSelf ccOperationWhenFailWithError:error];
    };
     
}

- (void) ccRHMergeVideos {
    [self ccMergeAndExportVideosAtFileURLs:_arrayVideoFiles];
}

- (void) ccRHPauseCapture{
    [_videoCamera pauseCameraCapture];
}

- (void) ccRHResumeCapture {
    [_videoCamera resumeCameraCapture];
}

- (void) ccRHSetTorchWithTorchMode : (CCTorchMode) torchMode {
    AVCaptureTorchMode captureTorchMode;
    AVCaptureFlashMode captureFlashMode;
    switch (torchMode) {
        case CCTorchModeOn:{
            captureTorchMode = AVCaptureTorchModeOn;
            captureFlashMode = AVCaptureFlashModeOn;
        }break;
        case CCTorchModeAuto:{
            captureTorchMode = AVCaptureTorchModeAuto;
            captureFlashMode = AVCaptureFlashModeAuto;
        }break;
        case CCTorchModeOff:{
            captureTorchMode = AVCaptureTorchModeOff;
            captureFlashMode = AVCaptureFlashModeOff;
        }break;
            
        default:
            break;
    }
    
    ccWeakSelf;
    if (_videoCamera.cameraPosition == AVCaptureDevicePositionBack) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            
            [pSelf.videoCamera.inputCamera lockForConfiguration:&error];
            
            [pSelf.videoCamera.inputCamera setFlashMode:captureFlashMode];
            [pSelf.videoCamera.inputCamera setTorchMode:captureTorchMode];
            
            [pSelf.videoCamera.inputCamera unlockForConfiguration];
            
#if DEBUG
            NSParameterAssert(!error);
#endif
        });
    }
}

- (void) ccRHFocusInPoint : (CGPoint)touchPoint {
    [self ccShowFocusPointAtRect:touchPoint];
    if (_videoCamera.cameraPosition == AVCaptureDevicePositionFront && _videoCamera.horizontallyMirrorFrontFacingCamera) {
        CGPoint pointCenter = _viewPrepare.center;
        touchPoint.x = (pointCenter.x - touchPoint.x) + pointCenter.x;
    }
    CGPoint pointDevice = [self ccConvertToPointOfInterestFromViewCoordinates:touchPoint];
    [self ccFocusWithMode:AVCaptureFocusModeAutoFocus
           exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
            atDevicePoint:pointDevice
 monitorSubjectAreaChange:YES];
}

- (void) ccRHChangeCamera {
    if (_isRecording) {
        return;
    }
    
    [_videoCamera stopCameraCapture];
    
    [_filter removeAllTargets];
    [_videoCamera removeAllTargets];
    
    _isRecording = NO;
    
    [self ccInitVideoCamera];
    
    [_videoCamera addTarget:_filter];
    [_filter addTarget:_viewOutput];
    
    [self ccAddMovieWriter];
    
    [_videoCamera startCameraCapture];
    
    _isBeautyOn = NO;
    [self ccRHAddBeautyFilter];
    
    /*
    // CRASH CODE , RELEASE WILL CAUSE CRASH !
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionBack) {
            backCamera = camera;
        } else {
            frontCamera = camera;
        }
    }
    
    if (isFront) {
        if (_videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
            return;
        }
        [_videoCamera.captureSession beginConfiguration];
        [_videoCamera.captureSession removeInput:_videoCamera.videoInput];
        AVCaptureDevice *deviceFront = frontCamera;
        
        [deviceFront lockForConfiguration:nil];
        if ([deviceFront isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [deviceFront setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [deviceFront unlockForConfiguration];
        
        _videoCamera.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:deviceFront error:nil];
        [_videoCamera.captureSession addInput:_videoCamera.videoInput];
        [_videoCamera.captureSession commitConfiguration];
    } else {
        if (_videoCamera.cameraPosition == AVCaptureDevicePositionBack) {
            return;
        }
        [_videoCamera.captureSession beginConfiguration];
        [_videoCamera.captureSession removeInput:_videoCamera.videoInput];
        AVCaptureDevice *deviceBack = backCamera;
        
        [deviceBack lockForConfiguration:nil];
        if ([deviceBack isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [deviceBack setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [deviceBack unlockForConfiguration];
        
        _videoCamera.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:deviceBack error:nil];
        [_videoCamera.captureSession addInput:_videoCamera.videoInput];
        [_videoCamera.captureSession commitConfiguration];
    }
     */
}

- (void) ccRHAddBeautyFilter {
    
    if (_isRecording) {
        return ;
    }
    
    [_filter removeTarget:_filterGroup];
    [_filter removeTarget:_movieWriter];
    [_filter removeTarget:_viewOutput];
    
    [_filterGroup removeTarget:_movieWriter];
    
    if (!_isBeautyOn) {
        [_filter addTarget:_filterGroup];
        [_filterGroup addTarget:_viewOutput];
        [_filterGroup addTarget:_movieWriter];
    } else {
        [_filter addTarget:_viewOutput];
        [_filter addTarget:_movieWriter];
    }
    _isBeautyOn = !_isBeautyOn;
}

- (void) ccRHDeleteLastVideo {
    if (_arrayVideoFiles.count == 0) {
        return ;
    }
    CCVideoInfo *videoInfo = (CCVideoInfo *)[_arrayVideoFiles lastObject];
    NSURL *urlFilePath = videoInfo.urlFilePath;
    CGFloat floatVideoDuration = videoInfo.floatDuration;
    
    _floatTotalDuration -= floatVideoDuration;
    
    [self ccDeleteWithFileURL:urlFilePath];
    [_arrayVideoFiles removeLastObject];
}
- (void) ccRHDeleteAllVideos {
    for (CCVideoInfo *videoInfo in _arrayVideoFiles) {
        NSURL *urlFile = videoInfo.urlFilePath;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *filePath = [[urlFile absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDirectory = NO;
            if ([fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
                if (isDirectory) {
                    return ;
                }
                NSError *error = nil;
                [fileManager removeItemAtPath:filePath error:&error];
                
                if (error) {
                    CCLog(@"deleteAllVideo删除视频文件出错:%@", error);
                }
            }
        });
    }
    _floatTotalDuration = 0.0f;
    [_arrayVideoFiles removeAllObjects];
}

/// 相机是否启用
+ (BOOL) ccIsCameraAllowed {
    //相机权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return !(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) ;
}

/// 麦克风是否启用
+ (BOOL) ccIsMicroPhoneAllowed {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return !(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) ;
}

/// 打开相机权限申请设置
+ (void) ccGuideToCameraSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Private Method (s)

- (instancetype)init {
    self = [super init];
    if (self) {
        [self ccDefaultSettings];
    }
    return self;
}

- (void) ccDefaultSettings {
    _isFront = YES;
    
    _arrayVideoFiles = [NSMutableArray array];
    _isRecording = NO;
    
    /// 美颜设置 -> 双滤波滤镜 -> 高斯滤镜(模糊 1.48f)
    _bilateraFilter = [[GPUImageBilateralFilter alloc] init];
    _gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    _gaussianBlurFilter.blurRadiusInPixels = 1.48f;
    
    [_bilateraFilter addTarget:_gaussianBlurFilter];
    
    _filterGroup = [[GPUImageFilterGroup alloc] init];
    
    [_filterGroup setInitialFilters:@[_bilateraFilter]];
    [_filterGroup setTerminalFilter:_gaussianBlurFilter];
    
    _isBeautyOn = YES;
    _floatTotalDuration = 0.0f;
    _floatCurrentVideoDuration = 0.0f;
}

- (void) ccStartTimerCount {
    _floatCurrentVideoDuration = 0.0f;
    _timer = [NSTimer scheduledTimerWithTimeInterval:_ccTimerDuration() target:self selector:@selector(ccTimerAction) userInfo:nil repeats:YES];
}

- (void) ccTimerAction {
    _floatCurrentVideoDuration += _ccTimerDuration();
    if ([_delegate respondsToSelector:@selector(ccVideoRecorder:didRecordingToOutPutFileAtURL:duration:recordedVideosTotalDur:)]) {
        [_delegate ccVideoRecorder:self didRecordingToOutPutFileAtURL:_urlCurrentFile duration:_floatCurrentVideoDuration recordedVideosTotalDur:_floatTotalDuration];
    }
    
    if ((_floatTotalDuration + _floatCurrentVideoDuration) >= _ccMaxDuration()) {
        [self ccRHStopRecording];
    }
}

- (void) ccStopTimerCount {
    [_timer invalidate];
    _timer = nil;
}

- (void) ccOperationWhenFailWithError : (NSError *) error {
    _floatTotalDuration -= _floatCurrentVideoDuration;
    _floatCurrentVideoDuration = 0.0f;
    if (_floatTotalDuration <= 0.0f) {
        _floatTotalDuration = 0.0f;
    }
    NSError *errorRecording = error ? error : [[NSError alloc] initWithDomain:@"com.EL.CCRecorder" code:CCCrashCodeStopRecordingError userInfo:@{NSLocalizedDescriptionKey:@"Stop Recording Error ,RECORDING TIME IS TOO SHORT"}];
    if ([_delegate respondsToSelector:@selector(ccVideoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
        [_delegate ccVideoRecorder:self didFinishRecordingToOutPutFileAtURL:_urlCurrentFile duration:_floatCurrentVideoDuration totalDur:_floatTotalDuration error:errorRecording];
    }
    [self ccDeleteWithFileURL:_urlCurrentFile];
}

- (void) ccShowFocusPointAtRect : (CGPoint) pointFocus{
    _imageViewFocus.alpha = 1.0f;
    _imageViewFocus.center = pointFocus;
    _imageViewFocus.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    ccWeakSelf;
    [UIView animateWithDuration:0.2f animations:^{
        pSelf.imageViewFocus.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.values = @[@0.5f, @1.0f, @0.5f, @1.0f, @0.5f, @1.0f];
        animation.duration = 0.5f;
        [pSelf.imageViewFocus.layer addAnimation:animation forKey:@"opacity"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3f animations:^{
                pSelf.imageViewFocus.alpha = 0;
            }];
        });
    }];
}
- (void) ccAddMovieWriter {
    if (_movieWriter) {
        [_filter removeTarget:_movieWriter];
        [_filterGroup removeTarget:_movieWriter];
    }
    
    _urlCurrentFile = _ccForURL([self ccGetVideoMergeFilePathString], YES);
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:_urlCurrentFile size:CGSizeMake(480.f, 640.f)];
//    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:_urlCurrentFile size:CGSizeMake(720.f, 1280.f)];
    
    _movieWriter.encodingLiveVideo = YES;
    
    _videoCamera.audioEncodingTarget = _movieWriter;
    
    if (_isBeautyOn) {
        [_filterGroup addTarget:_movieWriter];
    } else {
       [_filter addTarget:_movieWriter];
    }
    
}

- (void) ccInitVideoCamera {
    if (_videoCamera) {
        [_videoCamera removeAllTargets];
        _videoCamera.audioEncodingTarget = nil;
    }
    
    AVCaptureDevicePosition captureDevicePosition = _isFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:captureDevicePosition];
//    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:captureDevicePosition];
    
    [_videoCamera addAudioInputsAndOutputs];
    
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    ccWeakSelf;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        [pSelf.videoCamera.inputCamera lockForConfiguration:&error];
        if ([pSelf.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [pSelf.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [pSelf.videoCamera.inputCamera unlockForConfiguration];
    });
    
    /**
     *  实际上 , 可以录制更高的 , 但是在 GPUImage 源码中 , 定义 7_0 或者最高上限 是 30 
     *  超过 24f/s , 人眼就看不出区别了 ... 
     *  这里指定 帧 , 是为了切丢帧的那一帧 ...
     */
//    [_videoCamera setFrameRate:30];
//    CCLog(@"FrameRate : %d",_videoCamera.frameRate);
    
    _isFront = !_isFront;
}

- (void) ccDeleteWithFileURL : (NSURL *) urlFilePath {
    ccWeakSelf;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *stringFilePath = [[urlFilePath absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        if ([fileManager fileExistsAtPath:stringFilePath isDirectory:&isDirectory]) {
            if (isDirectory) {
                return ;
            }
//            unlink([stringFilePath UTF8String]);
            NSError *error = nil;
            [fileManager removeItemAtPath:stringFilePath error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([pSelf.delegate respondsToSelector:@selector(ccVideoRecorder:didRemoveVideoFileAtURL:totalDur:error:)]) {
                    [pSelf.delegate ccVideoRecorder:pSelf didRemoveVideoFileAtURL:urlFilePath totalDur:pSelf.floatTotalDuration error:error];
                }
            });
        }
    });
}

- (BOOL) ccIsFileExistAtURL : (NSURL *) urlFilePath {
    NSString *stringFilePath = [[urlFilePath absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if ([fileManager fileExistsAtPath:stringFilePath isDirectory:&isDirectory]) {
        if (isDirectory) {
            return NO;
        }
        return YES;
    } else {
        return NO;
    }
}

- (NSString *) ccGetVideoMergeFilePathString {
#warning CHANGE >>> WHEN CUSTOM
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
//    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    return fileName;
}

- (void)ccMergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray {
    
    if (!fileURLArray || !fileURLArray.count) {
        return ;
    }
    
    NSError *error = nil;
    
    CGSize renderSize = CGSizeMake(0, 0);
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    //先去assetTrack 也为了取renderSize
    NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
    for (CCVideoInfo *videoInfo in fileURLArray) {
        
        if (![self ccIsFileExistAtURL:videoInfo.urlFilePath]) {
            continue;
        }
        
        AVAsset *asset = [AVAsset assetWithURL:videoInfo.urlFilePath];
        
        if (!asset) {
            continue;
        }
        
        [assetArray addObject:asset];
        
        AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [assetTrackArray addObject:assetTrack];
        
        renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
        renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
    }
    
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    
    for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
        
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
        
#pragma mark - 祛除视频黑色闪烁
//        CGFloat floatEndTime = asset.duration.value / asset.duration.timescale;
        CGFloat floatEndTime = CMTimeGetSeconds(asset.duration) - 0.05f;
        CGFloat floatStartTime = 0.05f;
        CCLog(@"Start - End : %lf ~ %lf",floatStartTime,floatEndTime);
        CMTime timeStart = CMTimeMakeWithSeconds(floatStartTime, asset.duration.timescale);
        CMTime timeDuration = CMTimeMakeWithSeconds(floatEndTime - floatStartTime, asset.duration.timescale);
        CMTimeRange timeRange = CMTimeRangeMake(timeStart, timeDuration);
        
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
//                            ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
//                             atTime:totalDuration
//                              error:nil];
        [audioTrack insertTimeRange:timeRange
                            ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:totalDuration
                              error:nil];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
//                            ofTrack:assetTrack
//                             atTime:totalDuration
//                              error:&error];
        [videoTrack insertTimeRange:timeRange
                            ofTrack:assetTrack
                             atTime:totalDuration
                              error:&error];
        
        //fix orientationissue
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
//        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        totalDuration = CMTimeAdd(totalDuration, timeDuration);
        
        CGFloat rate;
        rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        
        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
#pragma mark - 调整缩放
//        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, - (assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0));//向上移动取中部影像
        
        /**
         *  向下移动取中部影像
         *  因为 GPUImageView 使用了 kGPUImageFillModePreserveAspectRatioAndFill 的 fillMode
         *  本身会向上偏移 , 所以需要向下偏移 .
         */
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, (assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0));//向下移动取中部影像
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
        
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        
        //data
        [layerInstructionArray addObject:layerInstruciton];
    }
#warning CHANGE >>> WHEN CUSTOM
    //get save path
    //    NSURL *mergeFileURL = [NSURL fileURLWithPath:[SBCaptureToolKit getVideoMergeFilePathString]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"test.mp4"];
    NSURL *mergeFileURL = [NSURL fileURLWithPath:path];
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (!isDirectory) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            NSParameterAssert(!error);
        }
    }
//    NSURL *mergeFileURL = [NSURL fileURLWithPath:NSHomeDirectory()];
    
    //export
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    ccWeakSelf;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([pSelf.delegate respondsToSelector:@selector(ccVideoRecorder:didFinishMergingVideosToOutPutFileAtURL:)]) {
                [pSelf.delegate ccVideoRecorder:self didFinishMergingVideosToOutPutFileAtURL:mergeFileURL];
            }
        });
    }];
}

- (CGPoint)ccConvertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _viewOutput.bounds.size;
    
//    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.preViewLayer;//需要按照项目实际情况修改
    
//    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
    if(_viewOutput.fillMode == kGPUImageFillModePreserveAspectRatioAndFill) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        
        for(AVCaptureInputPort *port in [_videoCamera.videoInput ports]) {//需要按照项目实际情况修改，必须是正在使用的videoInput
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
//                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                if(_viewOutput.fillMode == kGPUImageFillModePreserveAspectRatio) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
//                } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                } else if(_viewOutput.fillMode == kGPUImageFillModeStretch) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}


- (void)ccFocusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    CCLog(@"focus point: %f %f", point.x, point.y);
    ccWeakSelf;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = pSelf.videoCamera.inputCamera;
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported]) {
                [device setFocusPointOfInterest:point];
            }
            
            if ([device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
            }
            
            if ([device isExposurePointOfInterestSupported]) {
                [device setExposurePointOfInterest:point];
            }
            
            if ([device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
            }
            
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else {
            CCLog(@"对焦错误:%@", error);
        }
    });
}

- (void) dealloc {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (CCVideoInfo *tempModel in _arrayVideoFiles) {
//        unlink([tempFilePath UTF8String]);
        NSError *error = nil;
        NSURL *urlFile = tempModel.urlFilePath;
        NSString *stringFilePath = [urlFile.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        [fileManager removeItemAtPath:stringFilePath error:&error];
        if (error) {
            CCLog(@"dealloc error %@",error);
        }
    }
    
    [_videoCamera removeAllTargets];
    [_videoCamera removeTarget:_movieWriter];
    [_viewOutput removeFromSuperview];
    _viewOutput = nil;
    [_filter removeAllTargets];
    _filter = nil;
    _videoCamera = nil;
    _movieWriter = nil;
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
}

@end

#pragma mark - 设置 Video 的 信息

@implementation CCVideoInfo

@end
