//
//  CCRecordViewController.m
//  CCRecorder
//
//  Created by 冯明庆 on 16/7/21.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import "CCRecordViewController.h"
#import "CCRecorderHandler.h"

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "CCRecordProgressBar.h"

#import "CCPlayViewController.h"

#warning TODO >>> 
/**
 *  当添加点按或长按的操作 , 就是 UISwitch 时候 , 
 *  对它进行赋值 ,
 *  储存到本地 , 并用通知去改变 .
 */
static BOOL _isLongPressEnable = YES;

@interface CCRecordViewController () < CCRecorderHandlerDelegate >{
    NSInteger _integerFlashMode ;
    BOOL _isDidAppear;
    NSInteger _integerProgressBarDelete;
}

/// 录制 View 载体
@property (weak, nonatomic) IBOutlet UIView *viewRecording;
/// 进度条载体
@property (weak, nonatomic) IBOutlet UIView *viewProgressContent;
/// recording , delete , nextstep 等 Button 的 载体视图
@property (weak, nonatomic) IBOutlet UIView *viewOperationContent;

/// 返回按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonReturn;
- (IBAction)ccButtonActionReturn:(UIButton *)sender;

/// 闪光灯按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonFlash;
- (IBAction)ccButtonActionFlash:(UIButton *)sender;

/// 美颜按钮
@property (weak, nonatomic) IBOutlet UIButton *butonBeauty;
- (IBAction)ccButtonActionBeauty:(UIButton *)sender;

/// 变换摄像机按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonCameraChange;
- (IBAction)ccButtonActionChangeCamera:(UIButton *)sender;

/// 回删按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
- (IBAction)ccButtonActionDelete:(UIButton *)sender;

/// 下一步按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonNextStep;
- (IBAction)ccButtonActionNextStep:(UIButton *)sender;

/// 录制按钮
@property (weak, nonatomic) IBOutlet UIButton *buttonRecording;
- (IBAction)ccButtonActionRecoding:(UIButton *)sender;

@property (nonatomic , strong) CCRecorderHandler *handler;

@property (nonatomic , strong) CCRecordProgressBar *progressBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintViewRecordingHeight;

/// 初始化设置
- (void) ccInitDefaultSettings ;

/// 设置进度条
- (void) ccSetProgerssBar ;

/// 退出时提示
- (void) ccShowActionSheet ;

/// 返回上一级控制器
- (void) ccReturnToLastController ;

// 是否启用 BUTTON
- (void) ccOperateForButton : (BOOL) isEnable ;

- (void) ccSetFlashButton : (BOOL) isEnable ;

- (BOOL) ccIsCameraEnable ;
- (void) ccAskIfEnableCamera ;

@end

@implementation CCRecordViewController

#warning TODO >>>
/**
 *  需要添加每次进入都需要清空数据 ,
 *  清空缓存文件夹下所有缓存数据 , 包括合成的文件 , 
 *  返回之前将合成的文件 , 写入到草稿箱之中 .
 *
 *  BUGS :
 *      录制时候会将 闪 的一下给录制进去 , 
 *      不一定什么时候会将 闪 的一下录下来 . 可能是丢帧引起的 , 也可能是提前录制引起的
 *      好像还有 , 想起来再说 .
 *
 *  2017年05月25日14:53:27 早就解决了 , 现在又看到 , 解决办法是前后切除约 0.4s ... 🤣😂😂
 *                        至于 , 快速点击录制闪退的问题 ... 我的解决办法是 ... 阻隔用户响应 😂😂😂
 */

- (void)viewDidLoad {
    [super viewDidLoad];

    _layoutConstraintViewRecordingHeight.constant = _ccScreenWidth();
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_isDidAppear) {
        return;
    }
    
    [self ccInitDefaultSettings];
    [self ccSetProgerssBar];
    
    _isDidAppear = YES;
}

- (void) ccInitDefaultSettings {
    if (_isLongPressEnable) {
        /// 长摁必须禁交互
        _buttonRecording.userInteractionEnabled = NO;
    }
    
    _handler = [[CCRecorderHandler alloc] init];
    _handler.delegate = self;
    [_handler ccRHPrepareToRecordWithOutputView:_viewRecording];
    
    if (![self ccIsCameraEnable]) {
        [self ccAskIfEnableCamera];
    }
    
    [_viewRecording bringSubviewToFront:_viewProgressContent];
    
    _butonBeauty.selected = YES;
    _buttonCameraChange.selected = YES;
    
    _buttonDelete.enabled = NO;
    _buttonNextStep.enabled = NO;
    
    [self ccSetFlashButton:NO];
    
    _integerProgressBarDelete = 0;
    [_handler ccRHAddBeautyFilter];
}

- (void) ccSetProgerssBar {
    _viewProgressContent.width = _ccScreenWidth();
    _progressBar = [[CCRecordProgressBar alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         _viewProgressContent.width,
                                                                         _viewProgressContent.height)];
    [_viewProgressContent addSubview:_progressBar];
    [_progressBar ccStartShining];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self ccIsCameraEnable]) {
        [self ccAskIfEnableCamera];
        return;
    }
    
    _integerProgressBarDelete = 0;
    _buttonDelete.selected = NO;
    [_progressBar ccSetLastProgressToStyle:CCProgressTypeNormal];
    
    UITouch *touchFocus = [touches anyObject];
    CGPoint pointFocus = [touchFocus locationInView:self.view];
    if (CGRectContainsPoint(_viewRecording.frame, pointFocus)) {
        [_handler ccRHFocusInPoint:pointFocus];
        return ;
    }
    
    if (_isLongPressEnable) {
        if (!_buttonRecording.enabled) {
            return;
        }
        UITouch *touch = [touches anyObject];
        CGPoint pointTouch = [touch locationInView:_viewOperationContent];
//        _buttonRecording.selected = CGRectContainsPoint(_buttonRecording.frame, pointTouch) ? YES : NO;
        if (CGRectContainsPoint(_buttonRecording.frame, pointTouch)) {
            _buttonRecording.selected = YES;
            [_handler ccRHStartRecording];
        }
    }
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_isLongPressEnable) {
        if (!_buttonRecording.enabled) {
            return;
        }

        UITouch *touch = [touches anyObject];
        CGPoint pointTouch = [touch locationInView:_viewOperationContent];
        if (CGRectContainsPoint(_buttonRecording.frame, pointTouch)) {
            if (_buttonRecording.selected) {
                _buttonRecording.selected = NO;
                [_handler ccRHStopRecording];
                
//                [_buttonRecording setImage:[_ccImagePath(@"Icon_Record_Clicking") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
//                                  forState:UIControlStateSelected];
                _buttonRecording.selected = false;
                _buttonRecording.highlighted = false;
                
                /// 延迟启用 , 防止点击过快时候 , 编码未完成, 或实体为释放 所导致的崩溃 . 
                _buttonRecording.userInteractionEnabled = YES;
                ccWeakSelf;
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC));
                dispatch_after(time, dispatch_get_main_queue(), ^{
                    pSelf.buttonRecording.userInteractionEnabled = NO;
                });
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isLongPressEnable) {
        if (!_buttonRecording.enabled) {
            return;
        }
        
        UITouch *touch = [touches anyObject];
        CGPoint pointTouch = [touch locationInView:_viewOperationContent];
        if (!CGRectContainsPoint(_buttonRecording.frame, pointTouch)) {
//            [_buttonRecording setImage:[_ccImagePath(@"Icon_Record_Pause") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
//                              forState:UIControlStateHighlighted];
            _buttonRecording.highlighted = YES;
            _buttonRecording.selected = false;
        } else {
//            [_buttonRecording setImage:[_ccImagePath(@"Icon_Record_Clicking") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
//                              forState:UIControlStateSelected];
            _buttonRecording.highlighted = false;
            _buttonRecording.selected = YES;
        }
    }
}
 
- (IBAction)ccButtonActionReturn:(UIButton *)sender {
    [self ccShowActionSheet];
}

- (IBAction)ccButtonActionFlash:(UIButton *)sender {
    if (_buttonCameraChange.selected) {
        _buttonFlash.selected = NO;
        [self ccSetFlashButton:NO];
        return ;
    }
    
    _buttonFlash.selected = !_buttonFlash.selected;
    [self ccSetFlashButton:YES];
    CCTorchMode torchMode = _buttonFlash.selected ? CCTorchModeOn : CCTorchModeOff;
    [_handler ccRHSetTorchWithTorchMode:torchMode];
}

- (IBAction)ccButtonActionBeauty:(UIButton *)sender {
    if (_handler.isRecording) {
        return ;
    }
    _butonBeauty.selected = !_butonBeauty.selected;
    [_handler ccRHAddBeautyFilter];
}

- (IBAction)ccButtonActionChangeCamera:(UIButton *)sender {
    if (_handler.isRecording) {
        return ;
    }
    _buttonCameraChange.alpha = 1.0f;
    _buttonCameraChange.userInteractionEnabled = YES;
    
    _butonBeauty.selected = YES;
    _buttonFlash.selected = NO;
    [self ccSetFlashButton:sender.selected];
    sender.selected = !sender.selected;
    [_handler ccRHChangeCamera];
}

- (IBAction)ccButtonActionDelete:(UIButton *)sender {
    if (_integerProgressBarDelete == 0) {
        [_progressBar ccSetLastProgressToStyle:CCProgressTypeDelete];
        _buttonDelete.selected = YES;
        _integerProgressBarDelete = 1;
        return ;
    }
    if (_integerProgressBarDelete == 1) {
        if (_handler.arrayVideoFiles.count > 0) {
            [_handler ccRHDeleteLastVideo];
            [_progressBar ccDeleteLastProgress];
        }
        _buttonDelete.selected = NO;
        _integerProgressBarDelete = 0;
    }
    _buttonRecording.enabled = YES;
}

- (IBAction)ccButtonActionNextStep:(UIButton *)sender {
    [_handler ccRHMergeVideos];
}

- (IBAction)ccButtonActionRecoding:(UIButton *)sender {
    if (_isLongPressEnable) {
        return;
    }
    if (!_buttonRecording.selected) {
        [_handler ccRHStartRecording];
    } else {
        [_handler ccRHStopRecording];
    }
    _buttonRecording.selected = !_buttonRecording.selected;
}

- (void) ccShowActionSheet {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    ccWeakSelf;
    UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"取消"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {
        [pSelf dismissViewControllerAnimated:YES
                                 completion:^{
            
        }];
    }];
    UIAlertAction *alertActionRerecord = [UIAlertAction actionWithTitle:@"重新录制"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
        [pSelf.progressBar ccDeleteAllProgress];
        [pSelf.handler ccRHDeleteAllVideos];
                                                                    
        pSelf.buttonDelete.selected = NO;
        pSelf.buttonDelete.enabled = NO;
        pSelf.buttonNextStep.enabled = NO;
        pSelf.buttonRecording.enabled = YES;
    }];
    UIAlertAction *alertActionDiscard = [UIAlertAction actionWithTitle:@"放弃录制"
                                                                 style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction * _Nonnull action) {
        [pSelf.progressBar ccDeleteAllProgress];
        [pSelf.handler ccRHDeleteAllVideos];
//        [pSelf dismissViewControllerAnimated:YES completion:^{
            [pSelf ccReturnToLastController];
//        }];
    }];
    [alertC addAction:alertActionDiscard];
    [alertC addAction:alertActionRerecord];
    [alertC addAction:alertActionCancel];
    
    [self presentViewController:alertC
                       animated:YES
                     completion:^{
        
    }];
}
- (void) ccReturnToLastController {
    [_handler ccRHDeleteAllVideos];
#warning TODO >>>
    /**
     *  将 merging 的 视频 移动到草稿箱
     */
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
            
        }];
    }
}

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    if (_isDidAppear) {
        [_handler ccRHResumeCapture];
        [_progressBar ccSetLastProgressToStyle:CCProgressTypeNormal];
        _buttonDelete.selected = NO;
        _integerProgressBarDelete = 0;
    }
}
- (void) viewWillDisappear : (BOOL) animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [_handler ccRHPauseCapture];
}

#pragma mark - CCRecorderHandlerDelegate 
- (void) ccVideoRecorder:(CCRecorderHandler *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL {
    [_progressBar ccAddProgressView];
    [_progressBar ccStopShining];
    
    [self ccOperateForButton:NO];
}
- (void) ccVideoRecorder:(CCRecorderHandler *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error {
    
    CCLog(@"Record File %@ Duration %lf Now Total Duration %lf",outputFileURL,videoDuration,totalDur);
    
    [_progressBar ccStartShining];
    
    if (totalDur >= _ccMaxDuration()) {
        [self ccButtonActionNextStep:_buttonNextStep];
        _buttonRecording.enabled = NO;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            _buttonRecording.selected = NO;
        });
    }
    if (error) {
        CCLog(@"%@",error);
        [_progressBar ccDeleteLastProgress];
#warning TODO >>>
        /**
         *  提示 error
         */
    } else {
        
    }
    
    dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC));
    dispatch_after(time_t, dispatch_get_main_queue(), ^{
        [self ccOperateForButton:YES];
        _buttonDelete.enabled = _handler.arrayVideoFiles.count > 0;
    });
}
- (void) ccVideoRecorder:(CCRecorderHandler *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error {
    
    error ? CCLog(@"%@",error) : CCLog(@"Remove File %@ Now Total Duration %lf",fileURL,totalDur);
    
    if (_handler.arrayVideoFiles.count > 0) {
        _buttonDelete.enabled = YES;
    } else {
        _buttonDelete.enabled = NO;
        _buttonDelete.selected = NO;
    }
    _buttonNextStep.enabled = totalDur >= _ccMinDuration();
}
- (void) ccVideoRecorder:(CCRecorderHandler *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur {
    [_progressBar ccSetLastProgressToWidth:(videoDuration / _ccMaxDuration() * _progressBar.width)];
    _buttonNextStep.enabled = ((videoDuration + totalDur ) > _ccMinDuration());
}
- (void) ccVideoRecorder:(CCRecorderHandler *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL{
#warning TODO >>>
    /**
     *  将生成好的路径带到下一个页面 , 编辑页面
     */
    CCLog(@"%@",outputFileURL);
    
    CCPlayViewController *playVC = [[CCPlayViewController alloc] initWithVideoFileURL:outputFileURL];
    [self presentViewController:playVC animated:YES completion:^{
        
    }];
}

// 是否启用 BUTTON
- (void) ccOperateForButton : (BOOL) isEnable {
    CGFloat floatAlpah = isEnable ? 1.0f : 0.5f;
    
    _butonBeauty.alpha = floatAlpah;
    _butonBeauty.userInteractionEnabled = isEnable;
    
    _buttonCameraChange.alpha = floatAlpah;
    _buttonCameraChange.userInteractionEnabled = isEnable;
    
    _buttonDelete.enabled = isEnable;
    _buttonReturn.enabled = isEnable;
}

- (void) ccSetFlashButton : (BOOL) isEnable {
    if (isEnable) {
        _buttonFlash.enabled = YES;
        _buttonFlash.alpha = 1.0f;
    } else {
        _buttonFlash.enabled = NO;
        _buttonFlash.alpha = 0.5f;
    }
}

- (BOOL) ccIsCameraEnable {
    return [CCRecorderHandler ccIsCameraAllowed] && [CCRecorderHandler ccIsMicroPhoneAllowed];
}
- (void) ccAskIfEnableCamera {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提醒"
                                                                    message:@"请允许节拍使用相机和麦克风权限"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    ccWeakSelf;
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确认"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        [CCRecorderHandler ccGuideToCameraSettings];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [pSelf ccReturnToLastController];
    }];
    [alertC addAction:actionConfirm];
    [alertC addAction:actionCancel];
    [self presentViewController:alertC animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
- (BOOL) prefersStatusBarHidden {
    return YES;
}
 */

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    [_handler ccRHDeleteAllVideos];
    CCLog(@"_CC_RECORDER_VC_DEALLOC_");
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (BOOL) shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
#endif

@end
